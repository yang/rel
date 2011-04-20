- Talk about circular requires and having to put requires into methods
  e.g. predications.
- And the way around these circular dependencies. Putting the require
  inside of a function and needing to assign it to a variable before
  using it. This is referring to the Attributes including Predications.
- In AREL/test_select_manager:790 — the tests takes strings and takes
  literals are the same. One should actually take a string. Submit a
  pull request for that.
