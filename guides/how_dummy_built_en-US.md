
# Dummy Source Code Overview

---

**Dummy** is a demonstration application designed to showcase how to use **FlowCore** and extend its capabilities to meet specific business needs. The example use case focuses on an approval system, typical of FlowCore design scenarios.

## Features

The Dummy app primarily focuses on demonstrating how to implement key features of an approval system using FlowCore. Other non-essential features are either simplified or mock implementations, and any features not directly related to the workflow engine are omitted.

- **Mock User System**
  - Registration
  - Login / Switch identities
- **Dynamic Forms**
  - Create forms
  - CRUD operations on form fields
  - Set accessibility (read/write, read-only, hidden) for form fields
  - Override form field accessibility rules for custom approval tasks
- **Create and Edit Approval**
  - Link dynamic forms as approval forms
  - Visual configuration of approval workflows
    - Configure approval tasks
      - Optionally link approval opinion forms (approve, reject, comments, etc.)
      - Set form field accessibility for each approval task
    - Configure task callbacks
      - Notify approvers when assigned
    - Configure branch conditions using `mruby` scripts for evaluating form data
- **Submit for Approval**
  - Fill out initial form data before officially submitting for approval
  - The form data is shared across all approval steps, meaning changes at one step affect subsequent steps
  - A snapshot of the form data is taken at each step when submitted
  - Notifications are sent to the approver upon task assignment

## Preparing the Infrastructure

Before implementing the approval features, dependencies must be integrated, and configuration adjustments must be made.

### Monkey Patches

The following code in `config/application.rb` loads various monkey patches required for dynamic forms, the script engine, and other functionalities:

```ruby
Dir[Pathname.new(File.dirname(__FILE__)).realpath.parent.join("lib", "patches", "*.rb")].map do |file|
  require file
end
```

This loads monkey patches from the `/lib/patches` folder.

Here are some of the patches applied:

- (Dynamic Forms) Enhances `ActiveSupport::Concern` to support `prepend`. See `lib/patches/active_support/concern+prependable.rb`.
- (Script Engine) Adds `BigDecimal` and `Date/Time` support for MessagePack serialization.
  
Additionally, the following configuration in `config/application.rb` ensures that overrides are loaded from the `/app/overrides` folder:

```ruby
overrides = Rails.root.join("app/overrides")
Rails.autoloaders.main.ignore(overrides)
config.to_prepare do
  Dir.glob("#{overrides}/**/*_override.rb").each do |override|
    load override
  end
end
```

This ensures that custom logic, such as enhancements for Rails form builders and other functionality, is loaded correctly【5:12†source】.

### Integrating Virtual Models

Virtual models are Rails models inheriting from `ActiveModel`, not persisted in the database, designed to model serialized fields like workflow step configurations【5:12†source】.

---

### Integrating Dynamic Forms

Using the [FormCore](https://github.com/rails-engine/form_core) gem, Dummy integrates support for various field types, validation rules (compatible with ActiveRecord), and field accessibility control (read/write, read-only, hidden). 

Supported field types include:

- Boolean
- Integer / Integer Range
- Decimal / Decimal Range
- Date / Date Range
- Text
- Select / Multiple Select
- NestedForm / Multiple NestedForm

<details>
<summary>Related Code References</summary>

The core components for the dynamic forms feature are implemented in:

- The base class `form_core`
- ActiveModel validators for time-related rules

</details>

---

### Integrating the Script Engine

The [ScriptCore](https://github.com/rails-engine/script_core) gem integrates an `mruby` interpreter, allowing execution of `mruby` scripts in the workflow engine. Before using it, the interpreter must be built and compiled.

---

### Mock User System

Since Dummy is designed for local demonstrations, frequent user switching is necessary. Therefore, the user system is mock-implemented, allowing users to switch identities via the UI.

<details>
<summary>Related Code References</summary>

The mock user system includes migrations and a basic user model.

</details>

---

### Implementing Approval Workflow Types

The approval workflow binds to a form. FlowCore provides STI support for workflow definitions. The implementation involves:

1. Creating subclasses for `Workflow` and `Pipeline`, named `BusinessWorkflow` and `BusinessPipeline`
2. Adding associations to approval forms
3. Ensuring that workflow instances must have an initiator and valid initial form data【5:12†source】【5:14†source】.

---

### Implementing Approval Tasks

An approval task contains the following:

- Linked workflow instance
- Approval form and optional opinion form
- Form and opinion data
- Approver

Approval tasks can be expressed as a finite state machine (FSM) with states such as:

- Unassigned
- Assigned
- Form filled
- Completed

The model `HumanTask` is used to represent approval tasks. This model is linked to FlowCore tasks and includes business logic for task execution【5:13†source】.

---

### Implementing Task Triggers

Task triggers store workflow step configurations and execute code when a FlowCore task reaches a specific state. For the approval system, triggers are implemented to assign approvers, generate approval tasks, and manage form overrides【5:14†source】.

---

### Implementing Approval-Based Branch Conditions

FlowCore provides a model for branch conditions (`ArcGuard`), which can be extended using `ArcGuards::RubyScript` to evaluate `mruby` scripts. The branch condition checks form data to determine the next workflow step【5:14†source】.

---

### Implementing UI

(TODO: After UI refactoring continues)

---

This concludes the translation and summary of the document on how the Dummy application integrates FlowCore and extends it for an approval workflow system.
