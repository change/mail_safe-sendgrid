module Kernel
  def silence_warnings
    verbosity = $VERBOSE
    result = yield
    $VERBOSE = verbosity
    result
  end
end
