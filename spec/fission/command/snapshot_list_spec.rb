require File.expand_path('../../../spec_helper.rb', __FILE__)

describe Fission::Command::SnapshotList do
  include_context 'command_setup'

  before do
    @target_vm = ['foo']
    Fission::VM.stub!(:new).and_return(@vm_mock)

    @snap_list_response_mock = mock('snap_list_response')

    @vm_mock.stub(:name).and_return(@target_vm.first)
  end

  describe 'execute' do
    before do
      @vm_mock.stub(:snapshots).and_return(@snap_list_response_mock)
    end

    subject { Fission::Command::SnapshotList }

    it_should_not_accept_arguments_of [], 'snapshot list'

    it 'should output the list of snapshots if any exist' do
      @snap_list_response_mock.stub_as_successful ['snap 1', 'snap 2', 'snap 3']

      command = Fission::Command::SnapshotList.new @target_vm
      command.execute

      @string_io.string.should match /snap 1\nsnap 2\nsnap 3\n/
    end

    it 'should output that it could not find any snapshots if none exist' do
      @snap_list_response_mock.stub_as_successful []

      command = Fission::Command::SnapshotList.new @target_vm
      command.execute

      @string_io.string.should match /No snapshots found for VM '#{@target_vm.first}'/
    end

    it 'should output an error and exit if there was an error getting the list of snapshots' do
      @snap_list_response_mock.stub_as_unsuccessful

      command = Fission::Command::SnapshotList.new @target_vm
      lambda { command.execute }.should raise_error SystemExit

      @string_io.string.should match /There was an error listing the snapshots.+it blew up.+/m
    end

  end

  describe 'help' do
    it 'should output info for this command' do
      output = Fission::Command::SnapshotList.help

      output.should match /snapshot list vm_name/
    end
  end
end
