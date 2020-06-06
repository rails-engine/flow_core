def prepare
  input = @input || {}
  remove_instance_variable "@input"

  configuration = input[:configuration] || {}
  Time.formatted_offset = configuration[:time_zone_offset] || 0

  Input.load input[:payload]
end

def pack_output
  instance_variable_set "@output", Output.pack
end
