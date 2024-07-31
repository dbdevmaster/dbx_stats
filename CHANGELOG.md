# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

### [1.7.3](https://github.com/dbdevmaster/dbx_stats/compare/v1.7.2...v1.7.3) (2024-07-31)


### Bug Fixes

* get stale stats using bind for p_degree ([9f39d17](https://github.com/dbdevmaster/dbx_stats/commit/9f39d17923c00bdd52cfd4c5e6a34fdc6fddaff6))

### [1.7.2](https://github.com/dbdevmaster/dbx_stats/compare/v1.7.1...v1.7.2) (2024-07-31)


### Bug Fixes

* get stale stats using bind for p_degree ([23f34ed](https://github.com/dbdevmaster/dbx_stats/commit/23f34ed0e835aaf2effc731413f741fd6793661e))

### [1.7.1](https://github.com/dbdevmaster/dbx_stats/compare/v1.7.0...v1.7.1) (2024-07-31)


### Bug Fixes

* get stale stats in Parallel ([cb376e8](https://github.com/dbdevmaster/dbx_stats/commit/cb376e8569f207963c8c0ff81d274ceb0a45ad2a))

## [1.7.0](https://github.com/dbdevmaster/dbx_stats/compare/v1.6.3...v1.7.0) (2024-07-31)


### Features

* get stale stats in Parallel ([d2ec74a](https://github.com/dbdevmaster/dbx_stats/commit/d2ec74ac0d94a732248484454309784bdcc45f5f))


### Bug Fixes

* jobs status queued not getting enabled [#32](https://github.com/dbdevmaster/dbx_stats/issues/32) ([b5783bd](https://github.com/dbdevmaster/dbx_stats/commit/b5783bd8d3a53ecda04bd6b3eeeceabaf07ced99))

### [1.6.3](https://github.com/dbdevmaster/dbx_stats/compare/v1.6.2...v1.6.3) (2024-07-29)


### Bug Fixes

* distribute session correclty over cluster instance [#30](https://github.com/dbdevmaster/dbx_stats/issues/30) ([01294b7](https://github.com/dbdevmaster/dbx_stats/commit/01294b7e40fea23d30ff115ed7ab924d1880390f))
* distribute session correclty over cluster instance [#30](https://github.com/dbdevmaster/dbx_stats/issues/30) ([a4c16ed](https://github.com/dbdevmaster/dbx_stats/commit/a4c16ede41b4fe4d8d5a51de6d4f5ab717575013))
* distribute session correclty over cluster instance [#30](https://github.com/dbdevmaster/dbx_stats/issues/30) ([7de2e50](https://github.com/dbdevmaster/dbx_stats/commit/7de2e505c202745cd81113ce8ce9b421b59afe9d))
* distribute session correclty over cluster instance [#30](https://github.com/dbdevmaster/dbx_stats/issues/30) ([66fd858](https://github.com/dbdevmaster/dbx_stats/commit/66fd8583c164c8186a3054c77d88a787baf13a5b))
* distribute session correclty over cluster instance [#30](https://github.com/dbdevmaster/dbx_stats/issues/30) ([a2e6e17](https://github.com/dbdevmaster/dbx_stats/commit/a2e6e178376f5a12144e4c58d80022ed2f96a3fd))
* distribute session correclty over cluster instance [#30](https://github.com/dbdevmaster/dbx_stats/issues/30) ([981750f](https://github.com/dbdevmaster/dbx_stats/commit/981750f82e33d4acd6f37e6aba3f00e7210fa4f2))
* distribute session correclty over cluster instance [#30](https://github.com/dbdevmaster/dbx_stats/issues/30) ([da157ab](https://github.com/dbdevmaster/dbx_stats/commit/da157ab911bbdf881229f36f1b9333c003bbd63e))
* distribute session correclty over cluster instance [#30](https://github.com/dbdevmaster/dbx_stats/issues/30) ([67373c7](https://github.com/dbdevmaster/dbx_stats/commit/67373c798073d2de6cde0cab960393df68023aea))
* distribute session correclty over cluster instance [#30](https://github.com/dbdevmaster/dbx_stats/issues/30) ([c3dcad7](https://github.com/dbdevmaster/dbx_stats/commit/c3dcad7c7af42c699524bbaaf61e38ec8984a523))

### [1.6.2](https://github.com/dbdevmaster/dbx_stats/compare/v1.6.1...v1.6.2) (2024-07-29)


### Bug Fixes

* [#26](https://github.com/dbdevmaster/dbx_stats/issues/26) wait for job to comoplete before submitting new one not working ([cd6d754](https://github.com/dbdevmaster/dbx_stats/commit/cd6d754f7a17198a5fb49a8c627355f0109ee90c))
* degree ignore watcher job [#28](https://github.com/dbdevmaster/dbx_stats/issues/28) ([aa418fe](https://github.com/dbdevmaster/dbx_stats/commit/aa418fe4741189cb6b1718dcd6c42a8002a8b1c1))
* fetch_limit for gather index stats [#27](https://github.com/dbdevmaster/dbx_stats/issues/27) ([93421eb](https://github.com/dbdevmaster/dbx_stats/commit/93421eb375d40b83a6e9b0b41a8a62011ceed5fc))

### [1.6.1](https://github.com/dbdevmaster/dbx_stats/compare/v1.6.0...v1.6.1) (2024-07-29)


### Bug Fixes

* [#26](https://github.com/dbdevmaster/dbx_stats/issues/26) wait for job to comoplete before submitting new one not working ([992f31d](https://github.com/dbdevmaster/dbx_stats/commit/992f31d18a2d2653bd1f3d52ea8ae53222042301))

## [1.6.0](https://github.com/dbdevmaster/dbx_stats/compare/v1.5.11...v1.6.0) (2024-07-27)


### Features

* fetch limit during gather empty stale stats ([eecc559](https://github.com/dbdevmaster/dbx_stats/commit/eecc559d7212c2dfae9cdc59363997802b8c3939))

### [1.5.11](https://github.com/dbdevmaster/dbx_stats/compare/v1.5.10...v1.5.11) (2024-07-22)


### Bug Fixes

* [#24](https://github.com/dbdevmaster/dbx_stats/issues/24) use defer false on dbms_scheduler.drop_job ([26d48f0](https://github.com/dbdevmaster/dbx_stats/commit/26d48f0c353e48fd36e1523f7b129cf80cca0968))

### [1.5.10](https://github.com/dbdevmaster/dbx_stats/compare/v1.5.9...v1.5.10) (2024-07-22)


### Bug Fixes

* create watcher job ([4db0a8b](https://github.com/dbdevmaster/dbx_stats/commit/4db0a8b2742414800aab133ac82f412baff98208))

### [1.5.9](https://github.com/dbdevmaster/dbx_stats/compare/v1.5.8...v1.5.9) (2024-07-22)


### Bug Fixes

* [#23](https://github.com/dbdevmaster/dbx_stats/issues/23) stop_job not working replaced with drop_job ([95d0fbd](https://github.com/dbdevmaster/dbx_stats/commit/95d0fbd194e15dcf53e5eff0d62d02212a08a1ab))

### [1.5.8](https://github.com/dbdevmaster/dbx_stats/compare/v1.5.7...v1.5.8) (2024-07-19)


### Bug Fixes

* [#21](https://github.com/dbdevmaster/dbx_stats/issues/21) wrong instance_number in job_recod table ([b8f7ca3](https://github.com/dbdevmaster/dbx_stats/commit/b8f7ca31d121cb0f25aa1c5ea5e1b7cc466e9613))

### [1.5.7](https://github.com/dbdevmaster/dbx_stats/compare/v1.5.6...v1.5.7) (2024-07-19)


### Bug Fixes

* [#16](https://github.com/dbdevmaster/dbx_stats/issues/16), [#19](https://github.com/dbdevmaster/dbx_stats/issues/19) gather_schema_stats is not distributed over cluster instance ([6d2fd01](https://github.com/dbdevmaster/dbx_stats/commit/6d2fd0144e4c4eb0424aba5d3d55feeafcd269b2))

### [1.5.6](https://github.com/dbdevmaster/dbx_stats/compare/v1.5.5...v1.5.6) (2024-07-18)


### Bug Fixes

* dbs_stats_manger('job_auto_[drop|purg] is not droping | purging jobs [#17](https://github.com/dbdevmaster/dbx_stats/issues/17) ([255edc4](https://github.com/dbdevmaster/dbx_stats/commit/255edc4584bf49062a279b70469cda7c92aa7218))

### [1.5.5](https://github.com/dbdevmaster/dbx_stats/compare/v1.5.4...v1.5.5) (2024-07-18)


### Bug Fixes

* [#14](https://github.com/dbdevmaster/dbx_stats/issues/14) convert v_max_job_runtime to minutes ([0984b3c](https://github.com/dbdevmaster/dbx_stats/commit/0984b3c5804ddc4be1fe0f74b69f479c10196cae))

### [1.5.4](https://github.com/dbdevmaster/dbx_stats/compare/v1.5.3...v1.5.4) (2024-07-18)


### Bug Fixes

* [#12](https://github.com/dbdevmaster/dbx_stats/issues/12) ora-01403 no data found ([d718e97](https://github.com/dbdevmaster/dbx_stats/commit/d718e97e519770cbb6d43c1c5c06a7e96e801bd8))

### [1.5.3](https://github.com/dbdevmaster/dbx_stats/compare/v1.5.2...v1.5.3) (2024-07-18)


### Bug Fixes

* [#10](https://github.com/dbdevmaster/dbx_stats/issues/10) run dbx_<weekday> dbms_scheduler job ([ae48054](https://github.com/dbdevmaster/dbx_stats/commit/ae480545c7f95a987c56ee1ea4e6bf811bda5acd))

### [1.5.2](https://github.com/dbdevmaster/dbx_stats/compare/v1.5.1...v1.5.2) (2024-07-18)


### Bug Fixes

* syntax ([7a5242d](https://github.com/dbdevmaster/dbx_stats/commit/7a5242dc2c068183a7bdd748556042f8453f2af9))

### [1.5.1](https://github.com/dbdevmaster/dbx_stats/compare/v1.5.0...v1.5.1) (2024-07-18)


### Bug Fixes

* pls-00201 during package compile for [#8](https://github.com/dbdevmaster/dbx_stats/issues/8) issue ([51f2c25](https://github.com/dbdevmaster/dbx_stats/commit/51f2c25d7901d6e0dfb4f18e96a3072c4d37290c))
* run DBMS_SCHEDULER.RUN_JOB DBX_<WEEKDAY> syntax for [#6](https://github.com/dbdevmaster/dbx_stats/issues/6) issue ([beb9e81](https://github.com/dbdevmaster/dbx_stats/commit/beb9e816426a1572129bd66626eca95f0da837a6))

## [1.5.0](https://github.com/dbdevmaster/dbx_stats/compare/v1.4.13...v1.5.0) (2024-07-17)


### Features

* added procedure enable/disbale [#4](https://github.com/dbdevmaster/dbx_stats/issues/4) ([74444dc](https://github.com/dbdevmaster/dbx_stats/commit/74444dccef9efeb4041469f5206d273160162be2))

### [1.4.13](https://github.com/dbdevmaster/dbx_stats/compare/v1.4.12...v1.4.13) (2024-07-17)


### Bug Fixes

* watch_jobs issue [#2](https://github.com/dbdevmaster/dbx_stats/issues/2) ([9c3bd5a](https://github.com/dbdevmaster/dbx_stats/commit/9c3bd5a0da5687dcf1e0faa954876ea2014052a7))

### [1.4.12](https://github.com/dbdevmaster/dbx_stats/compare/v1.4.11...v1.4.12) (2024-07-17)


### Bug Fixes

* watch_jobs issue [#2](https://github.com/dbdevmaster/dbx_stats/issues/2) ([77bf0b4](https://github.com/dbdevmaster/dbx_stats/commit/77bf0b4ad8dd28129c472c9e733dec2d9e9267c3))

### [1.4.11](https://github.com/dbdevmaster/dbx_stats/compare/v1.4.10...v1.4.11) (2024-07-17)

### [1.4.10](https://github.com/dbdevmaster/dbx_stats/compare/v1.4.9...v1.4.10) (2024-07-17)


### Bug Fixes

* __REGEXP__% mapping ([7004ae9](https://github.com/dbdevmaster/dbx_stats/commit/7004ae9f31b4a6f700d24fd3ea6179a3fb0fe465))

### [1.4.9](https://github.com/dbdevmaster/dbx_stats/compare/v1.4.8...v1.4.9) (2024-07-17)


### Bug Fixes

* __REGEXP__% mapping changed v_regexp := LOWER(SUBSTR(p_schema_name, 11)); to v_regexp := LOWER(SUBSTR(p_schema_name, 12)); ([1f7a443](https://github.com/dbdevmaster/dbx_stats/commit/1f7a443f105d76457c7e1d525099e417fa118273))

### [1.4.8](https://github.com/dbdevmaster/dbx_stats/compare/v1.4.7...v1.4.8) (2024-07-17)


### Bug Fixes

* syntax missing ; ([0f38261](https://github.com/dbdevmaster/dbx_stats/commit/0f3826132fcf5042a9ee1edbade9c5480af9db3d))

### [1.4.7](https://github.com/dbdevmaster/dbx_stats/compare/v1.4.6...v1.4.7) (2024-07-17)


### Bug Fixes

* __REGEXP__% mapping changed v_regexp := LOWER(SUBSTR(p_schema_name, 11)); to v_regexp := LOWER(SUBSTR(p_schema_name, 12)); ([acde7b2](https://github.com/dbdevmaster/dbx_stats/commit/acde7b24fa0d1eeec56ac76a053d4a249e415972))

### [1.4.6](https://github.com/dbdevmaster/dbx_stats/compare/v1.4.5...v1.4.6) (2024-07-17)

### [1.4.5](https://github.com/dbdevmaster/dbx_stats/compare/v1.4.4...v1.4.5) (2024-07-17)

### [1.4.4](https://github.com/dbdevmaster/dbx_stats/compare/v1.4.3...v1.4.4) (2024-07-16)


### Bug Fixes

* parallel degree ([7cd3de1](https://github.com/dbdevmaster/dbx_stats/commit/7cd3de17e1c5cd86c20a2f391c53375333218f48))

### [1.4.3](https://github.com/dbdevmaster/dbx_stats/compare/v1.4.2...v1.4.3) (2024-07-16)


### Bug Fixes

* syntac during set dbms_application info action when gather index statistics ([ec31bd1](https://github.com/dbdevmaster/dbx_stats/commit/ec31bd172709af3354f7480a07dc97186454cdc3))

### [1.4.2](https://github.com/dbdevmaster/dbx_stats/compare/v1.4.1...v1.4.2) (2024-07-16)

### [1.4.1](https://github.com/dbdevmaster/dbx_stats/compare/v1.4.0...v1.4.1) (2024-07-16)


### Bug Fixes

* include gather index stats in create_gather_job ([5ccf5c8](https://github.com/dbdevmaster/dbx_stats/commit/5ccf5c87842c73fa0b16d94e69d2e500c15748d1))
* include index name in dbms_application_info action during gather_index_stats ([e526c5f](https://github.com/dbdevmaster/dbx_stats/commit/e526c5ff2695d577b95b32ce9d780995e3aee967))

## [1.4.0](https://github.com/dbdevmaster/dbx_stats/compare/v1.3.3...v1.4.0) (2024-07-16)


### Features

* include gather index stats in create_gather_job ([5e86706](https://github.com/dbdevmaster/dbx_stats/commit/5e86706119cc7d6a7f874e9630e92e47b26d1aef))

### [1.3.3](https://github.com/dbdevmaster/dbx_stats/compare/v1.3.2...v1.3.3) (2024-07-16)


### Bug Fixes

* syntax ([685d7f5](https://github.com/dbdevmaster/dbx_stats/commit/685d7f5e484349a027680750a614513f217c011f))

### [1.3.2](https://github.com/dbdevmaster/dbx_stats/compare/v1.3.1...v1.3.2) (2024-07-16)


### Bug Fixes

* gather_schema_stats job parallism ([09088f1](https://github.com/dbdevmaster/dbx_stats/commit/09088f1a92e52d54e08cc72f02506b451a5cd927))

### [1.3.1](https://github.com/dbdevmaster/dbx_stats/compare/v1.3.0...v1.3.1) (2024-07-15)


### Bug Fixes

* improved watch_jobs, exit when job is finished befor max_runtime or max_job_runtime ([7d7c2d2](https://github.com/dbdevmaster/dbx_stats/commit/7d7c2d2405c031372d0aefd1688e915d5228c346))

## [1.3.0](https://github.com/dbdevmaster/dbx_stats/compare/v1.2.1...v1.3.0) (2024-07-15)


### Features

* add uniq session identifier ([d1a3d5d](https://github.com/dbdevmaster/dbx_stats/commit/d1a3d5d79f8706f6f779b93a101c4a4cf107f1d7))


### Bug Fixes

* exit condition ([9596f56](https://github.com/dbdevmaster/dbx_stats/commit/9596f56b4ec7f4b2f4a987767e986b92fd719807))

### [1.2.1](https://github.com/dbdevmaster/dbx_stats/compare/v1.2.0...v1.2.1) (2024-07-15)


### Bug Fixes

* job_watch exit condition ([566712e](https://github.com/dbdevmaster/dbx_stats/commit/566712eba58a0dd865133762606608c7383dc6eb))

## [1.2.0](https://github.com/dbdevmaster/dbx_stats/compare/v1.1.4...v1.2.0) (2024-07-15)


### Features

* add watcher function to manager job status ([df9c299](https://github.com/dbdevmaster/dbx_stats/commit/df9c299df9583090e602287802588f1dec25e62a))

### [1.1.4](https://github.com/dbdevmaster/dbx_stats/compare/v1.1.3...v1.1.4) (2024-07-15)


### Bug Fixes

* job count where condition ([6babdb4](https://github.com/dbdevmaster/dbx_stats/commit/6babdb45e7fc4cb687ce24828ceac9c3abbb4463))

### [1.1.3](https://github.com/dbdevmaster/dbx_stats/compare/v1.1.2...v1.1.3) (2024-07-15)


### Bug Fixes

* dbms_scheduler job count ([2c8db4a](https://github.com/dbdevmaster/dbx_stats/commit/2c8db4a8e2cfee4936720ea55c045df55ef3c165))

### [1.1.2](https://github.com/dbdevmaster/dbx_stats/compare/v1.1.1...v1.1.2) (2024-07-15)


### Bug Fixes

* job_name not longer then 32 characters ([196f93c](https://github.com/dbdevmaster/dbx_stats/commit/196f93c7e2d6f7d0d010c8802ba4244f806e712d))

### [1.1.1](https://github.com/dbdevmaster/dbx_stats/compare/v1.1.0...v1.1.1) (2024-07-15)


### Bug Fixes

* PLS-00363: expression 'DBX_STATS_MANAGER(<null>, TO_CHAR(SQLDEVBIND1Z_2))' cannot be used as an assignment target ([97ba238](https://github.com/dbdevmaster/dbx_stats/commit/97ba23883d8abc1d52697c1822fe57d906d04674))

## [1.1.0](https://github.com/dbdevmaster/dbx_stats/compare/v1.0.2...v1.1.0) (2024-07-15)


### Features

* change dbms_lock to dbms_session ([d437b56](https://github.com/dbdevmaster/dbx_stats/commit/d437b568c7ff4f7d12ad701aee5191afde040543))


### Bug Fixes

* syntax ([4872fbe](https://github.com/dbdevmaster/dbx_stats/commit/4872fbe8466daa2b1483159cca247f63c20dea46))

### 1.0.2 (2024-07-14)

### 1.0.1 (2024-07-14)
