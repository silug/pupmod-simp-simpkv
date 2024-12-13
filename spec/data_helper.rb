module DataHelper
  require 'base64'

  def data_dir
    File.join(File.dirname(__FILE__), 'support', 'binary_data')
  end

  # @returns Hash of test data for different data types.
  #
  #   * key = description of the data type
  #   * value = Hash
  #     * :value              = Required Any. Value set with simpkv::put()
  #     * :metadata           = Required Hash. Value set with likv::put()
  #     * :serialized_value   = Required String. String value persisted in the store.
  #                             It is generated by the simpkv adapter from :value.
  #     * :deserialized_value = Optional String. Value restored by the simpkv adapter
  #                             from the stored value.  This is a problem that
  #                             could be fixed, but it is unclear if it is a
  #                             valid use case yet.
  #     * :skip               = Optional Boolean. When true, known problem with
  #                             serialization/deserialization that requires
  #                             significant rework.  May be addressed later.
  def data_info
    binary_file1_content = IO.read(File.join(data_dir, 'test_krb5.keytab')).force_encoding('ASCII-8BIT')

    binary_file2_content = IO.read(File.join(data_dir, 'random')).force_encoding('ASCII-8BIT')

    {
      'Boolean' => {
        value: true,
        metadata: { 'foo' => 'bar', 'baz' => 42 },
        serialized_value: '{"value":true,"metadata":{"foo":"bar","baz":42}}'
      },
      'valid UTF-8 String' =>  {
        value: 'some string',
        metadata: {},
        serialized_value: '{"value":"some string","metadata":{}}'
      },
      'malformed UTF-8 String' => {
        value: binary_file1_content.dup.force_encoding('UTF-8'),
        metadata: { 'foo' => 'bar', 'baz' => 42 },
        serialized_value:           '{"value":"' + Base64.strict_encode64(binary_file1_content) + '",' \
          '"encoding":"base64",' \
          '"original_encoding":"ASCII-8BIT",' \
          '"metadata":{"foo":"bar","baz":42}}',
        # only difference is encoding: deserialized value will have the
        # correct encoding of ASCII-8BIT, as the simpkv adapter 'fixes'
        # the encoding...this behavior is subject to change
        deserialized_value: binary_file1_content
      },
      'ASCII-8BIT String' => {
        value: binary_file2_content,
        metadata: { 'foo' => 'bar', 'baz' => 42 },
        serialized_value:           '{"value":"' + Base64.strict_encode64(binary_file2_content) + '",' \
          '"encoding":"base64",' \
          '"original_encoding":"ASCII-8BIT",' \
          '"metadata":{"foo":"bar","baz":42}}'
      },
      'Integer' => {
        value: 255,
        metadata: {},
        serialized_value: '{"value":255,"metadata":{}}'
      },
      'Float' => {
        value: 2.3849,
        metadata: { 'foo' => { 'bar' => 'baz' } },
        serialized_value: '{"value":2.3849,"metadata":{"foo":{"bar":"baz"}}}'
      },
      'Array of valid UTF-8 strings' => {
        value: [ 'valid UTF-8 1', 'valid UTF-8 2'],
        metadata: { 'foo' => 'bar', 'baz' => 42 },
        serialized_value:           '{"value":["valid UTF-8 1","valid UTF-8 2"],' \
          '"metadata":{"foo":"bar","baz":42}}'
      },
      'Array of binary strings' => {
        skip: 'Not yet supported',
        metadata: {},
        value: [
          binary_file1_content.dup.force_encoding('UTF-8'),
          binary_file2_content,
        ],
        serialized_value: 'TBD'
      },
      'Hash with valid UTF-8 strings' => {
        value: {
          'key1' => 'test_string',
          'key2' => 1000,
          'key3' => false,
          'key4' => { 'nestedkey1' => 'nested_test_string' }
        },
        metadata: { 'foo' => 'bar', 'baz' => 42 },
        serialized_value:           '{"value":' \
          '{' \
          '"key1":"test_string",' \
          '"key2":1000,' \
          '"key3":false,' \
          '"key4":{"nestedkey1":"nested_test_string"}' \
          '},' \
          '"metadata":{"foo":"bar","baz":42}}'
      },
      'Hash with binary strings' => {
        skip: 'Not yet supported',
        value: {
          'key1' => binary_file1_content.dup.force_encoding('UTF-8'),
          'key2' => 1000,
          'key3' => false,
          'key4' => { 'nestedkey1' => binary_file2_content }
        },
        metadata: {},
        serialized_value: 'TBD'
      }
    }
  end
end
