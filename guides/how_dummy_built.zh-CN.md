Dummy 源码解读
====

审批系统是 FlowCore 的典型设计场景，这里通过讲解 Dummy 应用的开发过程展示如何使用 FlowCore 以及如何扩展而满足业务需要。

## 功能清单

Dummy 聚焦展示如何用 FlowCore 实现审批系统的关键功能，故外围功能做了简化或假实现，同时与工作流引擎没有直接关系的功能也进行了省略。

- （假）用户系统
  - 注册
  - 登录/切换身份
- 动态表单
  - 创建表单
  - 增删改查表单字段
  - 表单字段可访问性（读写、只读、隐藏）设置
  - 可覆盖表单字段的可访问性规则（用于自定义审批任务的表单可访问性）
- 创建、编辑审批
  - 关联动态表单作为审批表单
  - （可视化）配置审批流程
    - 配置审批任务
      - 关联（可选）审批意见表单（通过、驳回、备注等）
      - 配置审批表单字段的可访问性
    - 配置审批任务回调
      - 审批分配审批人后为审批人发送通知
    - 配置流程分支条件
      - 使用 mruby 脚本对表单数据进行判断
- 发起审批
  - 正式发起审批前先填写初始的表单数据
  - 表单数据在审批的所有步骤中共享，也就是说在审批步骤中修改表单数据会影响之后的步骤
  - 每个审批步骤会快照提交时的表单数据
  - 分配审批人后会发送通知给审批人

## 准备基础设施

在开始实现审批功能前，需要集成依赖，调整配置

### 猴子补丁

<details>
<summary>相关代码索引</summary>

[config/application.rb](/test/dummy/config/application.rb) 中：

```ruby
Dir[Pathname.new(File.dirname(__FILE__)).realpath.parent.join("lib", "patches", "*.rb")].map do |file|
  require file
end
```

会从 [lib/patches](/test/dummy/lib/patches) 加载若干猴子补丁

- （动态表单）[lib/patches/active_support/concern+prependable.rb](/test/dummy/lib/patches/active_support/concern+prependable.rb) 增强 `ActiveSupport::Concern`，使其能够支持 `prepend`
- （脚本引擎）[lib/patches/big_decimal.rb](/test/dummy/lib/patches/big_decimal.rb) 增强 `BigDecimal`，使其支持 MessagePack 的序列化
- （脚本引擎）[lib/patches/date.rb](/test/dummy/lib/patches/date.rb) 增强 `Date`，使其支持 MessagePack 的序列化
- （脚本引擎）[lib/patches/time.rb](/test/dummy/lib/patches/time.rb) 增强 `Time`，使其支持 MessagePack 的序列化

```ruby
overrides = Rails.root.join("app/overrides")
Rails.autoloaders.main.ignore(overrides)
config.to_prepare do
  Dir.glob("#{overrides}/**/*_override.rb").each do |override|
    load override
  end
end
```

会从 [app/overrides](/test/dummy/app/overrides) 加载增强依赖的功能的代码

[app/overrides/action_view/helpers/form_builder_override.rb](/test/dummy/app/overrides/action_view/helpers/form_builder_override.rb)
增强了 Rails 的 Form builder，支持渲染错误信息

禁用 ActionView 对于模型字段错误的渲染行为，因为这会与 Bootstrap 的表单字段错误的 HTML 结构冲突：
[config/initializers/action_view.rb](/test/dummy/config/initializers/action_view.rb)

</details>

### 集成虚拟模型

虚拟模型是指继承 ActiveModel、没有数据库持久化的 Rails 模型，用于给序列化字段建模，如工作流的步骤的配置。

<details>
<summary>相关代码索引</summary>

相关依赖：

- 提供虚拟模型的基类 `activeentity`

相关目录：

- [app/lib/serializable_model](/test/dummy/app/lib/serializable_model)

</details>

### 集成动态表单

使用 [FormCore](https://github.com/rails-engine/form_core) 实现，是虚拟模型的一种应用，
支持多种字段类型，支持多种验证规则（与 ActiveRecord 的验证规则兼容），支持字段访问性控制（可读写、只读、隐藏），支持覆盖字段访问性控制。

支持的字段类型有：

- `Boolean` 布尔字段
- `Integer` 整型字段
- `IntegerRange` 整型范围字段
- `Decimal` 小数字段
- `DecimalRance` 小数范围字段
- `Date` 日期字段
- `DateRange` 日期范围字段
- `Datetime` 日期时间字段
- `DatetimeRange` 日期时间范围字段
- `Text` 文本字段
- `Select` 单选字段（值与显示内容相同）
- `MultipleSelect` 多选字段（值与显示内容相同）
- `Choice` 单选字段（值与显示内容不同）
- `MultipleChoice` 多选字段（值与显示内容不同）
- `NestedForm` 单值嵌套表单
- `MultipleNestedForm` 多值嵌套表单

<details>
<summary>相关代码索引</summary>

相关依赖：

- 提供动态表单的基类 `form_core`
- 为 ActiveModel 增加时间相关验证规则 `validates_timeliness`

相关数据库迁移：

- [db/migrate/20200205175440_create_form_kit_tables.rb](/test/dummy/db/migrate/20200205175440_create_form_kit_tables.rb)

相关目录：

- [app/models/form_kit](/test/dummy/app/models/form_kit)
- [app/models/concerns/form_kit](/test/dummy/app/models/concerns/form_kit)

其他：

- 使用 `cocoon` 在视图上渲染嵌套字段的添加和删除按钮
- 使用 `faker` 生成随机表单，方便测试
- 使用 `selectize-rails` 在视图上渲染选择字段（下拉框）
- 使用 [Presenter](/test/dummy/app/presenters) 封装视图层的渲染逻辑
- [app/views/_form_core](/test/dummy/app/views/_form_core) 存放视图层的各种可复用代码

</details>

### 集成脚本引擎

使用 [ScriptCore](https://github.com/rails-engine/script_core) 实现，项目内定制了 mruby 解释器，所以使用前需要在 Shell 执行

（如果在 FlowCore 根目录）
```
$ bin/rails app:script_core:engine:build
$ bin/rails app:script_core:engine:compile_lib
```

（如果在 Dummy 目录）
```
$ bin/rails script_core:engine:build
$ bin/rails script_core:engine:compile_lib
```

进行编译。

<details>
<summary>相关代码索引</summary>

相关依赖：

- `script_core`

相关目录：

- 项目定制 mruby 解释器目录 [mruby](/test/dummy/mruby)
- 简单封装，简化使用 [app/lib/script_engine.rb](/test/dummy/app/lib/script_engine.rb)

</details>

### （假）用户系统

由于 Dummy 用于单机演示功能，审批系统需要频繁切换用户，所以用户系统做了假实现，使用者可以在页面上随时切换当前登录用户。

<details>
<summary>相关代码索引</summary>

相关数据库迁移：

- [db/migrate/20200205175442_create_users.rb](/test/dummy/db/migrate/20200205175442_create_users.rb)

相关模型：

- [app/models/user.rb](/test/dummy/app/models/user.rb)

</details>

## 实现审批工作流类型

审批工作流的特点是流程绑定一个表单，FlowCore 为工作流定义预先支持了 STI，所以这里要做的是：

- 实现 Workflow 和 Pipeline（面向业务的描述语言）的审批工作流的子类（这里取名叫 `BusinessWorkflow` 和 `BusinessPipeline`）
- 增加对审批表单的关联
- 工作流实例创建时必须有发起人，且初始表单数据要合法

首先通过数据库迁移增加对表单的关联

```ruby
change_table :flow_core_pipelines do |t|
  # 关联审批表单
  t.references :form, foreign_key: { to_table: :form_kit_forms }
end

change_table :flow_core_workflows do |t|
  # 关联审批表单
  t.references :form, foreign_key: { to_table: :form_kit_forms }
end

change_table :flow_core_instances do |t|
  # 关联发起人
  t.references :creator, polymorphic: true
  # 关联审批表单
  t.references :form, foreign_key: { to_table: :form_kit_forms }
end
```

然后实现模型

```ruby
class BusinessPipeline < FlowCore::Pipeline
  # 关联审批表单
  belongs_to :form, class_name: "FormKit::Form"

  private

    # 在创建工作流时将审批表单绑定
    def on_build_workflow(workflow)
      workflow.form = form
    end

    # 指定工作流定义的类型
    def workflow_class
      FlowKit::BusinessWorkflow
    end
end

class BusinessWorkflow < FlowCore::Workflow
  # 关联审批表单
  belongs_to :form, class_name: "FormKit::Form"

  private

    # 在创建工作流实例时将审批表单绑定到实例上
    def on_build_instance(instance)
      instance.form = form
    end

    # 指定工作流实例的类型
    def instance_class
      FlowKit::BusinessInstance
    end
end

class BusinessInstance < FlowCore::Instance
  belongs_to :creator, polymorphic: true
  belongs_to :form, class_name: "FormKit::Form"

  # ...表单相关的业务代码（详见代码索引中的完整模型代码）
end
```

<details>
<summary>相关代码索引</summary>

相关数据库迁移：

- [db/migrate/20200205175441_add_columns_to_flow_core_tables.rb](/test/dummy/db/migrate/20200205175441_add_columns_to_flow_core_tables.rb)

相关模型：

- [app/models/flow_kit/business_pipeline.rb](/test/dummy/app/models/flow_kit/business_pipeline.rb)
- [app/models/flow_kit/business_workflow.rb](/test/dummy/app/models/flow_kit/business_workflow.rb)
- [app/models/flow_kit/business_instance.rb](/test/dummy/app/models/flow_kit/business_instance.rb)

</details>

## 实现审批任务

一个审批任务包含如下内容：

- 对应的工作流实例
- 审批表单
- （可选）自定义审批表单的字段访问性规则
- （可选）审批意见表单
- 审批表单和审批意见的数据
- 审批人

由于工作流实例已经关联了审批表单，
且工作流实例提供了全局的数据存储区（`FlowCore::Instance#payload`）和工作流端任务提供了数据存储区（`FlowCore::Task#payload`），
故这些字段不必在审批任务的数据表中实现。

审批任务还需要考虑到：

- 审批人指派、转发
- 草稿

可以使用一个简单的有限状态机（FSM）表达状态：

- 未指派审批人
- 已指派审批人，等待处理
- 已填写表单，等待提交
- 已完成

综合下来，便有了审批任务模型的表定义，效仿 Java 工作流引擎的命名，审批任务模型叫做 `HumanTask`，故数据库迁移代码如下：

```ruby
create_table :human_tasks do |t|
  t.references :workflow, foreign_key: { to_table: :flow_core_workflows } # 关联工作流，方便列出某工作流下任务这种常见的管理需求
  t.references :instance, foreign_key: { to_table: :flow_core_instances } # 关联工作流实例

  t.references :form_override, foreign_key: { to_table: :form_kit_form_overrides } # 关联自定义审批表单的字段访问性规则
  t.references :attached_form, foreign_key: { to_table: :form_kit_forms } # 关联审批意见表单

  t.references :assignable, polymorphic: true # 关联审批人，使用多态关联方便未来扩展支持指派人非用户的场景
  t.string :status, null: false # 状态

  t.datetime :assigned_at # 指派审批人的时间
  t.datetime :form_filled_at # 更新表单的时间
  t.datetime :finished_at # 完成时间

  t.timestamps
end
```

FlowCore 出于低耦合和保持逻辑清晰的需要，将任务拆分成了工作流任务（`FlowCore::Task`）和业务端的工作流托管任务，
接下来我们要让模型关联到工作流端任务，FlowCore 提供了 `FlowCore::TaskExecutable` Mixin，
只需要在 `HumanTask` 引入即可，模型代码如下：

```ruby
class HumanTask < ApplicationRecord
  # 关联工作流任务
  include FlowCore::TaskExecutable

  # 关联工作流
  belongs_to :workflow, class_name: "FlowCore::Workflow"
  # 关联工作流实例，并且设置 `autosave` 以便更新审批表单数据时自动保存
  belongs_to :instance, class_name: "FlowCore::Instance", autosave: true

  # 关联自定义审批表单的字段访问性规则
  belongs_to :form_override, class_name: "FormKit::FormOverride", optional: true

  # 关联审批意见表单
  belongs_to :attached_form, class_name: "FormKit::Form", optional: true
  # 关联审批人
  belongs_to :assignable, polymorphic: true

  enum status: {
    unassigned: "unassigned", # 未指派审批人
    assigned: "assigned", # 已指派审批人，等待处理
    form_filled: "form_filled", # 已填写表单，等待提交
    finished: "finished" # 已完成
  }

  # 工作流实例的共享存储区，存储审批表单的数据
  delegate :payload, to: :instance, prefix: :instance, allow_nil: false, private: true
  # `FlowCore::TaskExecutable` 包含了和工作流端任务的关联，引用后便可访问工作流端任务 `task`
  # 工作流任务的存储区，存储审批表单的数据
  delegate :payload, to: :task, prefix: :task, allow_nil: false, private: true

  # ...业务代码（详见代码索引中的完整模型代码）
end
```

额外要指出的是，`FlowCore::TaskExecutable` 包含了必须实现的方法 `finished?`，当该方法返回 `true` 时，
引擎将认为该步骤完成，推动流程继续，由于 `HumanTask` 刚好有 `finished` 状态且 `enum` 会自动生成 `finished?` 方法，
故这里我们不需要做任何事情。

<details>
<summary>相关代码索引</summary>

相关数据库迁移：

- [db/migrate/20200523233221_create_human_tasks.rb](/test/dummy/db/migrate/20200523233221_create_human_tasks.rb)

相关模型：

- [app/models/flow_kit/human_task.rb](/test/dummy/app/models/flow_kit/human_task.rb)

</details>

## 实现任务触发器：生成审批任务

任务触发器（`TransitionTrigger`）有两个作用：

- 储存工作流步骤的配置
- 当引擎任务进入特定状态时执行代码

结合我们的审批任务，我们需要实现审批任务的触发器，用途包含：

- （可选）关联自定义审批表单的字段访问性规则
- （可选）关联审批意见表单
- 审批人指派方法
  - 指派给审批发起人
  - 从审批人候选列表中抽取
- 关联审批人候选列表
- 在工作流端启动时创建审批任务

FlowCore 提供了支持 STI 的 `FlowCore::TransitionTrigger` 模型作为触发器基类，继承它即可

```ruby
class TransitionTriggers::HumanTask < FlowCore::TransitionTrigger
end
```

接下来我们需要添加关联

```ruby
change_table :flow_core_transition_triggers do |t|
  t.references :attached_form, foreign_key: { to_table: :form_kit_forms }
  t.references :form_override, foreign_key: { to_table: :form_kit_form_overrides }
end

# 审批人候选人列表，使用审批候选人使用多态关联方便未来扩展
create_table :assignee_candidates do |t|
  t.references :assignable, polymorphic: true, null: false
  t.references :trigger, null: false, foreign_key: { to_table: :flow_core_transition_triggers }

  t.timestamps
end
```

审批候选人模型

```ruby
class AssigneeCandidate < ApplicationRecord
  belongs_to :assignable, polymorphic: true
  belongs_to :trigger, class_name: "FlowCore::TransitionTrigger"
end
```

`FlowCore::TransitionTrigger` 预留了用于序列化用途的长文本类型的 `configuration` 字段，利用基础设施中的虚拟模型，可以将配置结构化。

```ruby
class HumanTask
  class Configuration < SerializableModel::Base
    ASSIGN_TO_ENUM = {
      instance_creator: "instance_creator", # 审批人为流程发起人
      candidate: "candidate" # 审批人从候选人列表中选择
    }.freeze

    attribute :assign_to, :string, default: ASSIGN_TO_ENUM[:instance_creator]
    enum assign_to: ASSIGN_TO_ENUM,
         _prefix: :assign_to

    validates :assign_to,
              presence: true
  end
end
```

最后，综合起来，得出审批任务的触发器模型定义

```ruby
class TransitionTriggers::HumanTask < FlowCore::TransitionTrigger
  belongs_to :attached_form, class_name: "FormKit::Form", optional: true
  belongs_to :form_override, class_name: "FormKit::FormOverride", optional: true

  has_many :assignee_candidates, foreign_key: :trigger_id, inverse_of: :trigger, dependent: :delete_all
  has_many :assignee_candidate_users, through: :assignee_candidates, source: :assignable, source_type: "User"

  serialize :configuration, Configuration

  # 如果审批人是从候选列表中抽取时，要至少有一个候选人
  validates :assignee_candidates,
            length: { minimum: 1 },
            if: ->(r) { r.configuration.assign_to_candidate? }

  # `FlowCore::TransitionTrigger` 提供的 helper 方法，返回 `true` 表明这个触发器允许配置，方便 UI 渲染配置链接
  def configurable?
    true
  end

  # 在部署流程的时候 FlowCore 会对配置深拷贝避免后续修改影响正在执行的流程，这里需要额外处理审批人候选人列表的复制
  def dup
    obj = super
    obj.assignee_candidate_user_ids = assignee_candidate_user_ids
    obj
  end
end
```

最后，实现 `on_task_enable(task)` 接口，在工作流端的任务创建时根据配置创建审批任务便大功告成

```ruby
class TransitionTriggers::HumanTask < FlowCore::TransitionTrigger
  # ...

  # 在工作流端任务启动时
  def on_task_enable(task)
    transaction do
      assignee =
        case configuration.assign_to
        when Configuration::ASSIGN_TO_ENUM[:candidate] # 如果是从审批人候选人列表中抽取
          assignee_candidates.order("random()").first&.assignable # 随机抽取
        when Configuration::ASSIGN_TO_ENUM[:instance_creator] # 如果是指派给发起人
          task.instance&.creator
        else
          raise "Invalid `assign_to` value - #{configuration.assign_to}"
        end

      human_task = task_class.create! task: task, attached_form: attached_form, form_override: form_override, status: :unassigned
      human_task.assign! assignee
    end
  end
end
```

<details>
<summary>相关代码索引</summary>

相关数据库迁移：

- [db/migrate/20200523233225_create_assignee_candidates.rb](/test/dummy/db/migrate/20200523233225_create_assignee_candidates.rb)

相关模型：

- [app/models/flow_kit/transition_triggers/human_task.rb](/test/dummy/app/models/flow_kit/transition_triggers/human_task.rb)
- [app/models/flow_kit/transition_triggers/human_task/configuration.rb](/test/dummy/app/models/flow_kit/transition_triggers/human_task/configuration.rb)

</details>

## 实现基于审批表单的分支判断

FlowCore 提供了支持 STI 的 `FlowCore::ArcGuard` 模型作为分支比较器基类，
在基础设施中已经集成了使用 mruby 的表达式引擎，
这里需要做的是继承 `FlowCore::ArcGuard` 实现 `ArcGuards::RubyScript`。

使用的手法同前几步。

```ruby
class ArcGuards::RubyScript < FlowCore::ArcGuard
  # 同样使用虚拟模型来储存配置，ArcGuard 已经预留了用于序列化的 `configuration` 字段
  serialize :configuration, Configuration

  # ArcGuard 要求必须实现的接口，用于在进行分支判断时调用
  def permit?(task)
    # 把当前任务的表单数据（提交时的审批表单数据和审批意见表单数据）传入进 mruby 脚本引擎
    # 在内部可以用 Input[:form_attributes]["FIELD_KEY"] 访问审批表单的字段，
    # 使用 Input[:attached_form_attributes]["FIELD_KEY"] 访问审批意见表单的字段
    result = ScriptEngine.run_inline configuration.script, payload: task.payload
    if result.errors.any?
      raise "Script has errored"
    end

    # 返回结果，真或假
    result.output
  end

  # `FlowCore::ArcGuard` 提供的 helper 方法，用于方便在 UI 渲染分支的描述信息
  def description
    configuration.name
  end

  # `FlowCore::ArcGuard` 提供的 helper 方法，返回 `true` 表明这个触发器允许配置，方便 UI 渲染配置链接
  def configurable?
    true
  end
end

class ArcGuards::RubyScript
  # 用于保存配置信息的虚拟模型
  class Configuration < SerializableModel::Base
    attribute :name, :string
    # 运行在 mruby 脚本引擎的代码
    attribute :script, :string

    validates :name, :script,
              presence: true
  end
end
```

<details>
<summary>相关代码索引</summary>

相关模型：

- [app/models/flow_kit/arc_guards/ruby_script.rb](/test/dummy/app/models/flow_kit/arc_guards/ruby_script.rb)
- [app/models/flow_kit/arc_guards/ruby_script/configuration.rb](/test/dummy/app/models/flow_kit/arc_guards/ruby_script/configuration.rb)

</details>

## 实现 UI

TODO：UI 重构后继续
