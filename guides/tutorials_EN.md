
# User Guide

---

## Requirements

- Rails 6.0+
- Ruby 2.5+
- A relational database supported by ActiveRecord

## Installation

### Add Dependency to `Gemfile`

In your project's `Gemfile`, add:

```ruby
gem "flow_core"
```

Or use the latest development version:

```ruby
gem 'flow_core', github: 'rails-engine/flow_core'
```

Then run `bundle` to update the project dependencies.

### Copy Database Migration Files

Run the following command to copy the required migration files for FlowCore:

```
$ bin/rails role_core:install:migrations
```

After copying, run the migration:

```
$ bin/rails db:migrate
```

## Implementing Workflow-Managed Tasks

Assume there is a `Todo` model like this:

```ruby
class Todo < ActiveRecord::Base
  # Task status enum: pending, in_progress, completed
  enum status: %i[pending in_progress completed]
end
```

You need to include `FlowCore::TaskExecutable` in the `Todo` model and implement the required methods.

```ruby
class Todo < ActiveRecord::Base
  enum status: %i[pending in_progress completed]

  include FlowCore::TaskExecutable

  def finished?
    status == "completed"
  end

  delegate :payload, to: :instance, prefix: :instance, allow_nil: false, private: true
  delegate :payload, to: :task, prefix: :task, allow_nil: false, private: true
end
```

FlowCore automatically completes the workflow task when the `Todo` task is marked as finished.

## Implementing Task Triggers

Assume the `Todo` model has been implemented. To create a trigger for `Todo`, create a class that inherits from `FlowCore::TransitionTrigger`.

```ruby
class TodoTrigger < FlowCore::TransitionTrigger
  def configurable?
    true
  end

  def on_task_enable(task)
    initial_status = configuration[:initial_status] || "in_progress"
    Todo.create! task: task, status: initial_status
  end
end
```

...

Additional sections covering **Branch Guards**, **Workflow Types**, and **Workflow Creation** are included in the full document.
