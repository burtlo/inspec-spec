# InSpec Spec

This repository explores adding testing to the InSpec controls
that you define within your InSpe Resource Pack.

> A Resource Pack is an InSpec profile that defines its own
> resource without any controls that exercise it.

InSpec resource tests are written in RSpec with additional
helper content found in the `spec/spec_helper.rb` file to
make the tests easier to compose. The tests are run through
the RSpec binary `rspec`.

## Installation

To run the tests you will have to have the RSpec test runner
available to you. RSpec is installed alongside InSpec. You can
run it from where it embedded within your InSpec installation.

```bash
$ /opt/inspec/embedded/bin/rspec
```

## Setup

To setup the testing within your profile you will need to create
a `spec` directory and add the `spec/spec_helper.rb` file found
in this repository.

Within your `spec/spec_helper.rb` you will need to require all
the inspec resources defined in the profile's `libraries` directory.

```ruby
require 'inspec'
require 'rspec/its'
require 'libraries/ohai.rb'

# To test each of your resources, they will need to be required
# to have the InSpe registry know about it.
require 'libraries/ohai.rb'

# ... rest of the spec_helper.rb ...
```

Now you will define test file for each of your resources. The file
should exist within the `spec` directory and end with `_spec.rb`.

For example, to create a test file for an ohai resource, found in
`libraries/ohai.rb`, I would create a file named `spec/ohai_spec.rb`.

At the start of this test file you will want to require the contents
of the `spec_helper` file to ensure it loads all the necessary dependencies,
resources defined in your libraries directory, and the helpers defined
in that file.

Second, you want to define a `describe_inspec_resource` example group
that sets the stage for the resource testing. Within that group you can arrange
your tests with `describe` and `context` to create the scenarios and
conditions you want to test.

Within any context you can define an `environment` block
which defines the various operations and responses that the
InSpec/Train backend may receive. These environments build
on one another within the nested contexts. This helps you
define layers of conditions that build on one another.

Examples can be written out in either `its` or `it`. When defining
the `its`, the symbol specified within the `its` is the message
to send to the resource in the context. Within the `it` block
you can express expectations against the InSpec resource under
test, through the `resource` helper.

```ruby
require 'spec_helper'

describe_inspec_resource 'ohai' do
  context 'relying on the automatic path' do
    environment do
      command('which ohai').returns(stdout: '/path/to/ohai')
      command('/path/to/ohai --version').returns(stdout: "Ohai: 14.8.10\n")
    end

    its(:version) { should eq '14.8.10' }

    it 'has a version' do
      expect(resource.version).to eq('14.8.10')
    end

    context 'with no parameters' do
      context 'top-level attributes' do
        environment do
          command('/path/to/ohai').returns(result: {
            stdout: '{ "os": "darwin" }', exit_status: 0
          })
        end

        it 'are accessible via dot-notation' do
          expect(resource.os).to eq('darwin')
        end
      end
    end
  end
end
```
