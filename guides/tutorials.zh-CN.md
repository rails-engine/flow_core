使用指南
====

## 要求

- Rails 6.0+
- Ruby 2.5+
- ActiveRecord 支持的关系型数据库

## 安装

### 添加依赖到 `Gemfile`

在项目的 `Gemfile` 里添加：

```ruby
gem "flow_core"
```

或者使用最新的开发版本：

```ruby
gem 'flow_core', github: 'rails-engine/flow_core'
```

然后执行 `bundle` 更新项目依赖

### 复制数据库迁移文件

执行

```
$ bin/rails role_core:install:migrations
```

拷贝 FlowCore 需要的数据库表的迁移文件

然后执行迁移

```
$ bin/rails db:migrate
```

## 实现工作流托管任务

假设有这样一个 `Todo` 模型

```ruby
class Todo < ActiveRecord::Base
  # 任务状态的枚举，pending 还没开始做，in_progress 正在进行中，completed 已完成
  enum status: %i[pending in_progress completed]
end
```

你需要为 `Todo` 模型引入 `FlowCore::TaskExecutable` 并实现必要的方法

```ruby
class Todo < ActiveRecord::Base
  # 任务状态的枚举，pending 还没开始做，in_progress 正在进行中，completed 已完成
  enum status: %i[pending in_progress completed]

  include FlowCore::TaskExecutable

  # 必须实现此方法，以便工作流获取该记录是否完成
  def finished?
    status == "completed"
  end

  # （可选）工作流托管任务可以访问工作流实例和工作流任务
  # 工作流实例的共享存储区
  delegate :payload, to: :instance, prefix: :instance, allow_nil: false, private: true
  # 工作流任务的存储区
  delegate :payload, to: :task, prefix: :task, allow_nil: false, private: true
end
```

`FlowCore::TaskExecutable` 会为模型添加 `after_save` 回调，当 `Todo` 记录保存时如果 `finished?` 为 `true`，
会自动尝试完成工作流任务。

参考案例见 [Dummy 源码解读 —— 实现审批任务](how_dummy_built.zh-CN.md#实现审批任务)

## 实现任务触发器

假设已经实现了 `Todo` 托管任务模型。

实现一个继承 `FlowCore::TransitionTrigger` 的类做为 `Todo` 的触发器

```ruby
class TodoTrigger < FlowCore::TransitionTrigger
  # `FlowCore::TransitionTrigger` 提供的 helper 方法，返回 `true` 表明这个触发器允许配置，方便 UI 渲染配置链接
  def configurable?
    true
  end

  # 必须实现，在工作流任务启动时触发托管任务
  def on_task_enable(task)
    # `FlowCore::TransitionTrigger` 有一个用于储存设置信息的 `configuration` 序列化字段
    # 假设这里我们从中获取要创建 `Todo` 任务的初始状态
    initial_status = configuration[:initial_status] || "in_progress"
    # 一定要使用 `task: task` 将托管任务与工作流任务关联起来
    # 使用 `create!` 以便创建因异常失败时回滚到上一个工作流的状态
    Todo.create! task: task, status: initial_status
  end
end
```

参考案例见 [Dummy 源码解读 —— 实现任务触发器：生成审批任务](how_dummy_built.zh-CN.md#实现任务触发器：生成审批任务)

## 实现分支比较器

WIP

参考案例见 [Dummy 源码解读 —— 实现基于审批表单的分支判断](how_dummy_built.zh-CN.md#实现基于审批表单的分支判断)

## 扩展工作流类型

WIP

参考案例见 [Dummy 源码解读 —— 实现审批工作流类型](how_dummy_built.zh-CN.md#实现审批工作流类型)

## 创建工作流

### 使用 Pipeline

WIP，参考 [Pipeline 规则说明](pipeline.zh-CN.md)

### 使用 PetriNet DSL

WIP，参考 [dummy/db/seeds.rb](../test/dummy/db/seeds.rb)

## 使用工作流

像普通 ActiveRecord 模型那样获取一条工作流记录

```ruby
wf = Workflow.first
```

调用 `Workflow#create_instance` 方法创建工作流实例

```ruby
instance = wf.create_instance
```

调用 `Instance#activate` 启动工作流

```ruby
instance.activate
```
