module Kakine
  class SecurityRule
    attr_reader :id, :direction, :protocol, :port_range_max, :port_range_min, :remote_ip, :remote_group, :ethertype

    def initialize(rule, tenant_name, sg_name)
      @tenant_name = tenant_name
      @sg_name = sg_name

      rule.each do|k,v|
        instance_variable_set(eval(":@#{k.to_s}"), v) unless k.include?("port")
      end

      @port_range_min, @port_range_max = *convert_port_format(rule)
    end

    def ==(target_sg)
      %i(@direction @protocol @port_range_max @port_range_min @remote_ip @remote_group @ethertype).all? do |val|
        self.instance_variable_get(val) == target_sg.instance_variable_get(val)
      end
    end

    def convert_port_format(rule)
      unless format = port?(rule) || icmp?(rule) || range?(rule)
        raise(Kakine::SecurityRuleError, "no match port format")
      end
      format
    end

    def port?(rule)
      [rule['port'] ,rule['port']] if rule.has_key?('port')
    end

    def icmp?(rule)
      if rule.has_key?('type') && rule.has_key?('code')
        [rule['type'] ,rule['code']]
      end
    end

    def range?(rule)
      if rule.has_key?('port_range_max') && rule.has_key?('port_range_min')
        [rule['port_range_min'] ,rule['port_range_max']]
      end
    end

    def remote_group_id
      if !!@remote_group
        unless remote_security_group = Kakine::Resource.get(:openstack).security_group(@tenant_name, @remote_group)
          raise(Kakine::SecurityRuleError, "not exists #{@remote_group}")
        end
        remote_security_group.id
      end
    end
  end
end
