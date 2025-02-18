module Orthoses
  class Content
    # Check and drop duplication method, const etc...
    class DuplicationChecker
      def initialize(decl, env: nil)
        @decl = decl
        @env = env || Utils.rbs_environment(collection: true)
      end

      def update_decl
        return unless @decl.respond_to?(:members)
        uniq_map = {}
        @decl.members.each do |member|
          if member.instance_of?(RBS::AST::Members::MethodDefinition) && member.overload
            # avoid to duplicate and keep order
            uniq_map[Object.new] = member
          else
            key = member_key(member)
            drop_member = uniq_map[key]
            uniq_map[key] = member
            if drop_member
              Orthoses.logger.info("#{@decl.name} \"#{member.location.source}\" was droped since duplication")
            end
          end
        end
        drop_known_method_definition(uniq_map)
        @decl.members.replace(uniq_map.values)
      end

      private

      def drop_known_method_definition(uniq_map)
        decl_name = @decl.name.absolute!
        if m_entry = @env.class_decls[decl_name]
          m_entry.decls.each do |d|
            d.decl.members.grep_v(RBS::AST::Members::LocationOnly).each do |member|
              uniq_map.delete(member_key(member))
            end
          end
        end

        constants_in_uniq_map = uniq_map.select do |key, value|
          value.kind_of?(RBS::AST::Declarations::Constant)
        end
        constants_in_uniq_map.each do |key, value|
          type_name = decl_name + value.name
          if @env.constant_decls[type_name]
            uniq_map.delete(key)
          end
        end
      end

      def member_key(member)
        case member
        when RBS::AST::Members::MethodDefinition
          # member.types.hash is different
          [member.class, member.name, member.kind]
        when RBS::AST::Members::LocationOnly
          [member.class]
        when RBS::AST::Members::Alias
          [RBS::AST::Members::MethodDefinition, member.new_name, member.kind]
        when RBS::AST::Members::AttrAccessor
          # FIXME: how to check "#{member.name}=" ?
          [RBS::AST::Members::MethodDefinition, member.name, member.kind]
        when RBS::AST::Members::AttrReader
          [RBS::AST::Members::MethodDefinition, member.name, member.kind]
        when RBS::AST::Members::AttrWriter
          [RBS::AST::Members::MethodDefinition, "#{member.name}=", member.kind]
        else
          [member.class, member.name]
        end
      end
    end
  end
end
