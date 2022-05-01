# Vdmc-Core
This package contains the vdmc-core setup for Apex development. It contains DI, trigger framework over several packages up to the Nebula logger with Sentry integration.

## Dependency Injection
Dependency injection provides a pattern for larger custom software solutions. It forces the developer
to access the business logic only through a facade. The facade itself can be fetched via Dependency Injection
from anywhere. All retrieved services are cached for the current session. This enables the reduction of unneeded,
class initialization.

## Trigger Framework (forked from [codefriar](https://github.com/codefriar/DecouplingWithSimonGoodyear))
Based on the trigger framework from codefriar, it includes additional changes. It includes feature toggles for specific TriggerHandler
via the "Active__c" flag on the MDT object.

## Nebula-Logger (used from [jongpie](https://github.com/jongpie/NebulaLogger))
Take a look at the linked repository. It's just a great logging framework that Salesforce never had.

### Sentry Integration
Own implementation to also transmit occuring events to sentry. It simply allows to better monitor multiple
environments.
