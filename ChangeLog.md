trino-client-ruby
====
## 1.0.1
- Merge pull request [#73](https://github.com/treasure-data/trino-client-ruby/issues/73) from pedrombl/update-faraday [[2a6482c](https://github.com/treasure-data/trino-client-ruby/commit/2a6482c)]
- Merge pull request [#74](https://github.com/treasure-data/trino-client-ruby/issues/74) from takezoe/alias-gem [[6829f5b](https://github.com/treasure-data/trino-client-ruby/commit/6829f5b)]
- Add a script to publish two gems at once [[2eea152](https://github.com/treasure-data/trino-client-ruby/commit/2eea152)]
- Add alias gem 'trino-client-ruby' [[597d332](https://github.com/treasure-data/trino-client-ruby/commit/597d332)]
- Bump faraday version from 0.12 to 1.0 [[cd7864f](https://github.com/treasure-data/trino-client-ruby/commit/cd7864f)]
- Merge pull request [#72](https://github.com/treasure-data/trino-client-ruby/issues/72) from miniway/trino_add_error_type [[2aa365a](https://github.com/treasure-data/trino-client-ruby/commit/2aa365a)]
- Add error_type and error_location at TrinoQueryError [[e3598c1](https://github.com/treasure-data/trino-client-ruby/commit/e3598c1)]

## 1.0.0
- Migration to Trino ([#70](https://github.com/treasure-data/trino-client-ruby/issues/70)) [[933db57](https://github.com/treasure-data/trino-client-ruby/commit/933db57)]
- Setup GitHub Actions ([#71](https://github.com/treasure-data/trino-client-ruby/issues/71)) [[697d20f](https://github.com/treasure-data/trino-client-ruby/commit/697d20f)]

## 0.6.5
- Add gzip option ([#68](https://github.com/treasure-data/presto-client-ruby/issues/68)) [[1f43629](https://github.com/treasure-data/presto-client-ruby/commit/1f43629)]
- Bump tiny-presto to 0.0.7 to use docker image in GitHub Container Registry ([#69](https://github.com/treasure-data/presto-client-ruby/issues/69)) [[57b5045](https://github.com/treasure-data/presto-client-ruby/commit/57b5045)]

## 0.6.4
- Merge pull request [#67](https://github.com/treasure-data/presto-client-ruby/issues/67) from takezoe/update-readme-follow-redirect-option [[6da5025](https://github.com/treasure-data/presto-client-ruby/commit/6da5025)]
- Update README.md to describe follow_redirect option [[83f8a05](https://github.com/treasure-data/presto-client-ruby/commit/83f8a05)]
- Merge pull request [#66](https://github.com/treasure-data/presto-client-ruby/issues/66) from takezoe/follow-redirect-option [[9f1b297](https://github.com/treasure-data/presto-client-ruby/commit/9f1b297)]
- Update lib/presto/client/faraday_client.rb [[64c0b81](https://github.com/treasure-data/presto-client-ruby/commit/64c0b81)]
- Add follow_redirect option [[a103660](https://github.com/treasure-data/presto-client-ruby/commit/a103660)]
- Create CODEOWNERS [[c8c3251](https://github.com/treasure-data/presto-client-ruby/commit/c8c3251)]

## 0.6.3
- Merge pull request [#56](https://github.com/treasure-data/presto-client-ruby/issues/56) from miniway/more_recent_statementclient [[423ff42](https://github.com/treasure-data/presto-client-ruby/commit/423ff42)]
- Make more similar to recent java StatementClient [[94f5193](https://github.com/treasure-data/presto-client-ruby/commit/94f5193)]
- Test with presto docker container ([#62](https://github.com/treasure-data/presto-client-ruby/issues/62)) [[fe8af11](https://github.com/treasure-data/presto-client-ruby/commit/fe8af11)]
- Add pull request template [[7b286cc](https://github.com/treasure-data/presto-client-ruby/commit/7b286cc)]

## 0.6.2
- Release 0.6.2 [[68f5b27](https://github.com/treasure-data/presto-client-ruby/commit/68f5b27)]
- Merge pull request [#61](https://github.com/treasure-data/presto-client-ruby/issues/61) from treasure-data/implement_query_id [[6f3f236](https://github.com/treasure-data/presto-client-ruby/commit/6f3f236)]
- Merge pull request [#60](https://github.com/treasure-data/presto-client-ruby/issues/60) from treasure-data/fix_test [[01fa867](https://github.com/treasure-data/presto-client-ruby/commit/01fa867)]
- Merge pull request [#59](https://github.com/treasure-data/presto-client-ruby/issues/59) from treasure-data/update_readme [[50b2e2a](https://github.com/treasure-data/presto-client-ruby/commit/50b2e2a)]
- Update test target ruby versions [[2b65462](https://github.com/treasure-data/presto-client-ruby/commit/2b65462)]
- Update description of model_version [[750232e](https://github.com/treasure-data/presto-client-ruby/commit/750232e)]
- Remove old ruby versions [[28b1abb](https://github.com/treasure-data/presto-client-ruby/commit/28b1abb)]
- Enable fail_on_error [[9c1112a](https://github.com/treasure-data/presto-client-ruby/commit/9c1112a)]
- Fix tests which is only effective when presto version is less than 313 [[695966e](https://github.com/treasure-data/presto-client-ruby/commit/695966e)]
- Implement `StatementClient#query_id` [[2b692ca](https://github.com/treasure-data/presto-client-ruby/commit/2b692ca)]
- url encode properties ([#57](https://github.com/treasure-data/presto-client-ruby/issues/57)) [[8450627](https://github.com/treasure-data/presto-client-ruby/commit/8450627)]


## 0.6.1
* Fix WriterTarget 316 model class name

## 0.6.0
* Support presto 316 model class

## 0.5.14
* Added `Query#current_results_headers` that returns HTTP response headers

## 0.5.13
* Added `query_timeout` and `plan_timeout` options with default disabled
* Changed timer to use CLOCK_MONOTONIC to avoid unexpected behavior when
  system clock is updated

## 0.5.12
* Upgrade to Presto 0.205 model

## 0.5.11
* Support multiple session properties
* Check invalid JSON data response

## 0.5.10
* Added client_info, client_tags, and http_headers options.

## version 0.5.9
* Added error_name field at PrestoQueryError

## 0.5.8
* Added `Client#kill(query_id)` method.
* Added additional checking of internal exceptions so that client doesn't
  silently return in case when Presto query is killed and Presto returns a
  valid `200 OK` response with `result_uri: null`.
* Fixed `undefined local variable 'body'` error that was possibly happening
  when Presto returned an unexpected data structure.

## 0.5.7
* Support a password option with HTTP basic auth
* Changed retry timeout from hard coded 2h to configurable default 2min
* Fix too deep nested json failure

## 0.5.6:
* Added missing inner class models for version 0.178

## 0.5.5:
* Added support for model version 0.178

## 0.5.4:
* Support "Content-Type: application/x-msgpack" for more efficient parsing of
  HTTP response body.
* Added "enable_x_msgpack: true" option to send Accept header with
  application/x-msgpack.

## 0.5.3:
* Added support for model version 0.173.
* Changed the default latest model version to 0.173.
* Fixed compatibility with the new major version of Farady
* Require Faraday 0.12 or later

## 0.5.2:
* Relax dependent version of Faraday to be able to use all 0.x versions.
* Fix build script that was broken due to new major version of rake.

## 0.5.1:
* Assume ConnectorId as a primitive type to be able to decode "connectorId"
  fields.

## 0.5.0:
* Support multiple model versions
* Added support for model version 0.153.
* Changed the default latest model version to 0.513.

## 0.4.17:
* Added support for :ssl option.

## 0.4.16:
* Upgraded Presto model version to 0.151

## 0.4.15:
* decode method of model classes validate Hash type

## 0.4.14:
* Added support for resuming fetching query results by using new `Query.resume(next_uri, options)` method (@tetrakai++)

## 0.4.13:
* Added support for :http_proxy option to use a HTTP proxy server
* Added support for hashed Client response using `run_with_names` (thanks to MoovWeb for allowing me to contribute)
* Upgraded Presto model version to 0.134

## 0.4.5:
* Upgraded Presto model version to 0.99

## 0.4.3:
* Updated gem dependency to accept faraday ~> 0.9.x as well as ~> 0.8.8

## 0.4.2:
* Added support for :properties option to set session properties introduced
since Presto 0.78

## 0.4.1:
 Added EquiJoinClause model class
* Added StageId#query_id and #id methods
* Added TaskId#query_id, #stage_id and #id methods

## 0.4.0:
* Added Query#current_results, #advance and #query_info for advanced users
* Generate model classes from Presto source code to include complete classes

## 0.3.3:
* Added :time_zone and :language options added by Presto 0.66

## 0.3.2:
* Fixed a problem that client skips the last chunk if result is large

## 0.3.1:
* Added http_debug option
* Disabled HTTP debug logging by default

## 0.3.0:
* Added http_timeout option
* Added http_open_timeout option
* Changed Query.start API to start(query, options) to http options

## 0.2.0:
* Added Query#cancel
* Added Query#close
* Added Client#run
* Changed required_ruby_version from 1.9.3 to 1.9.1

## 0.1.0:
* First release
