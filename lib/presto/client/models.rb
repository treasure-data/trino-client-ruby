#
# Presto client for Ruby
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
module Presto::Client

  ####
  ## lib/presto/client/models.rb is automatically generated using "rake modelgen:latest" command.
  ## You should not edit this file directly. To modify the class definitions, edit
  ## modelgen/models.rb file and run "rake modelgen:latest".
  ##

  module ModelVersions
  end

  require 'presto/client/model_versions/0.149.rb'
  require 'presto/client/model_versions/0.153.rb'
  require 'presto/client/model_versions/0.173.rb'
  require 'presto/client/model_versions/0.177.rb'

  Models = ModelVersions::V0_177

end
