module Glassy::Kernel
  class Context
    STORE_MAPPINGS = [Nil, String, Int32, Int64, Float64, Bool]

    macro finished
      alias StoreTypes = Union({{ *STORE_MAPPINGS }}, {{ *STORE_MAPPINGS.map { |v| "Array(#{v})".id } }})
      @store = {} of String => StoreTypes
    end

    def get(name : String)
      @store[name]
    end

    def set(name : String, value : StoreTypes)
      @store[name] = value
    end

    def get?(name : String)
      @store[name]?
    end

    def store
      @store
    end

    def merge(context2 : Context) : Context
      @store.merge!(context2.store)
      self
    end
  end
end
