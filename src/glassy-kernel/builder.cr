require "./context"

module Glassy::Kernel
  class Builder(T)
    alias Context = Glassy::Kernel::Context

    @parent_context : Context

    def initialize(@strategy : Proc(Context, T), context : Context? = nil)
      if context.nil?
        @parent_context = Context.new
      else
        @parent_context = context
      end
    end

    def make : T
      make(Context.new)
    end

    def make(context : Context?) : T
      if context.nil?
        context = Context.new
      end

      @strategy.call(@parent_context.merge(context.not_nil!))
    end
  end
end
