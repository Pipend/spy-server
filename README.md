[![Build Status](https://travis-ci.org/Pipend/spy-server.svg?branch=master)](https://travis-ci.org/Pipend/spy-server)    [![Coverage Status](https://coveralls.io/repos/Pipend/spy-server/badge.svg?branch=master&service=github)](https://coveralls.io/github/Pipend/spy-server?branch=master)

# Install
`git clone git@github.com:Pipend/spy-server.git`

# Setup

* `npm install`

* `npm run configure` - this creates `config.ls` in the project directory (update it with your list of projects and the corresponding storage details)

* `lsc server.ls`

# Testing & Coverage

* `gulp build` to transpile livescript files to javascript
* `npm test` & `npm run coverage` for unit tests & coverage

