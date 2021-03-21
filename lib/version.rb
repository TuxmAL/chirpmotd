# frozen_string_literal: true

# The ChirpQuote module is responsible for tweetting
# some messages generate by modules that you can add
# in the <tt>modules</tt> folder. 
# Here we define the version number.
module ChirpQuote
  VERSION = '0.2.0'

  # The main class ChirpMotd.
  # Here we define the version method
  class ChirpMotd
    def version
      ChirpQuote::VERSION
    end
  end
end
