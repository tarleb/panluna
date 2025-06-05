# Release Checklist

- Create a new rockspec:

  + Copy last rockspec to new release name.
  + Bump the version in the new file.
  + Make additional changes to the file if necessary.

- Finalize the CHANGELOG.md.

- Commit new rockspec, updated changelog.

- Push, wait for the tests to finish.

- Upload rockspec to <https://luarocks.org/>, either via the web
  interface, or with

  ``` sh
  luarocks upload --api-key "$(pass show ...)" <rockspec>
  ```
