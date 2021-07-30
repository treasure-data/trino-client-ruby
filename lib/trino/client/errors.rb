#
# Trino client for Ruby
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#
module Trino::Client
  class TrinoError < StandardError
  end

  class TrinoHttpError < TrinoError
    def initialize(status, message)
      super(message)
      @status = status
    end

    attr_reader :status
  end

  class TrinoClientError < TrinoError
  end

  class TrinoQueryError < TrinoError
    def initialize(message, query_id, error_code, error_name, error_type, error_location, failure_info)
      super(message)
      @query_id = query_id
      @error_code = error_code
      @error_name = error_name
      @error_type = error_type
      @error_location = error_location
      @failure_info = failure_info
    end

    attr_reader :error_code, :error_name, :error_type, :error_location, :failure_info
  end

  class TrinoQueryTimeoutError < TrinoError
  end
end
