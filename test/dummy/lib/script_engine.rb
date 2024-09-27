# frozen_string_literal: true

module ScriptEngine
  class << self
    ENGINE_PATH = Rails.root.join("mruby")

    def engine
      @engine ||= ScriptCore::Engine.new ENGINE_PATH.join("bin")
    end

    def precompile(code, with_lib: true)
      wrapped_code =
        if with_lib
          "prepare; Output.value = class Object\n#{code}\nend; pack_output"
        else
          code
        end

      mrbc_executable = ENGINE_PATH.join("bin/mrbc").realpath
      tmp_dir = Rails.root.join("tmp")
      lib_files = with_lib ? Dir[ENGINE_PATH.join("lib/**/*.rb").to_s] : []

      code_sha = Digest::SHA2.hexdigest(wrapped_code)
      tmp_rb = tmp_dir.join("#{code_sha}.rb")
      tmp_output = tmp_dir.join("#{code_sha}.mrb")
      cmd = "#{mrbc_executable} --remove-lv -o #{tmp_output} #{lib_files.join(' ')} #{tmp_rb}"

      File.write tmp_rb, wrapped_code
      system(cmd, exception: true)

      compiled = File.binread tmp_output

      FileUtils.rm([tmp_rb, tmp_output])

      compiled
    end

    def run(
      string, payload: nil,
      instruction_quota: nil, instruction_quota_start: nil, memory_quota: nil, timeout: nil
    )
      sources = [
        %w[preparing prepare],
        ["user", string],
        %w[packing_output pack_output]
      ]

      engine.eval sources,
                  input: {
                    configuration: {
                      time_zone_offset: Time.zone.formatted_offset(false)
                    },
                    payload: payload
                  },
                  environment_variables: { "TZ" => Time.zone.name },
                  instruction_quota: instruction_quota,
                  instruction_quota_start: instruction_quota_start,
                  memory_quota: memory_quota,
                  timeout: timeout
    end

    def run_inline(
      string, payload: nil,
      instruction_quota: nil, instruction_quota_start: nil, memory_quota: nil, timeout: nil
    )
      run "Output.value = class Object\n#{string}\nend",
          payload: payload,
          instruction_quota: instruction_quota,
          instruction_quota_start: instruction_quota_start,
          memory_quota: memory_quota,
          timeout: timeout
    end

    def run_precompiled(
      binary_mrb, payload: nil,
      instruction_quota: nil, instruction_quota_start: nil, memory_quota: nil, timeout: nil
    )
      engine.eval_mrb binary_mrb,
                      input: {
                        configuration: {
                          time_zone_offset: Time.zone.formatted_offset(false)
                        },
                        payload: payload
                      },
                      environment_variables: { "TZ" => Time.zone.name },
                      instruction_quota: instruction_quota,
                      instruction_quota_start: instruction_quota_start,
                      memory_quota: memory_quota,
                      timeout: timeout
    end
  end
end
