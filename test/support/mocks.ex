Hammox.defmock(Funbox.GithubClient.Mock, for: Funbox.GithubClient)
Hammox.defmock(Funbox.ContentParser.Mock, for: Funbox.ContentParser)
Hammox.defmock(Funbox.ContentTransformer.Mock, for: Funbox.ContentTransformer)

defmodule Mock do
  @moduledoc false

  def allow_to_call_impl(module, method, arity) do
    impl = Function.capture(Module.concat(module, Impl), method, arity)
    Hammox.expect(module.impl(), method, impl)
  end
end
