require 'spec_helper'

describe Trino::Client::ColumnValueParser do
  def column_value(data, type)
    column = Struct.new(:type, :name).new(type)
    Trino::Client::ColumnValueParser.new(column).value(data)
  end

  it 'parses varchar values' do
    data = 'a string'
    type = 'varchar'
    expected_value = 'a string'
    expect(column_value(data, type)).to eq(expected_value)
  end

  it 'parses timestamp values' do
    data = '2022-07-01T14:53:02Z'
    type = 'timestamp with time zone'
    expected_value = Time.parse(data)
    expect(column_value(data, type)).to eq(expected_value)
  end

  it 'parses array type values' do
    data = [1, 2, 3, 4]
    type = 'array(integer, integer, integer, integer)'
    expected_value = [1, 2, 3, 4]
    expect(column_value(data, type)).to eq(expected_value)
  end

  it 'parses row type values' do
    data = [
      'userId',
      'userLogin',
      'SKU_FREE',
      'TYPE_USER',
      '2022-07-01T14:53:02Z',
      ''
    ]
    type = 'row(id varchar, "name" varchar, plan_sku varchar, type varchar, created_at timestamp with time zone, organization_tenant_name varchar)'
    expected_value = {
      'id' => 'userId',
      'name' => 'userLogin',
      'plan_sku' => 'SKU_FREE',
      'type' => 'TYPE_USER',
      'created_at' => Time.parse('2022-07-01T14:53:02Z'),
      'organization_tenant_name' => ''
    }
    value = column_value(data, type)
    expect(column_value(data, type)).to eq(expected_value)
    expect(value['created_at'].is_a?(Time)).to eq true
  end

  it 'parses an array of row type values' do
    data = [[
      'userId',
      'userLogin',
      'SKU_FREE',
      'TYPE_USER',
      '2022-07-01T14:53:02Z',
      ''
    ]]
    type = 'array(row(id varchar, "name" varchar, plan_sku varchar, type varchar, created_at timestamp with time zone, organization_tenant_name varchar))'
    expected_value = [{
      'id' => 'userId',
      'name' => 'userLogin',
      'plan_sku' => 'SKU_FREE',
      'type' => 'TYPE_USER',
      'created_at' => Time.parse('2022-07-01T14:53:02Z'),
      'organization_tenant_name' => ''
    }]
    value = column_value(data, type)
    expect(column_value(data, type)).to eq(expected_value)
    expect(value[0]['created_at'].is_a?(Time)).to eq true
  end

  it 'parses row type values that have an array in them' do
    data = [
      'userId',
      %w[userLogin1 userLogin2],
      'value'
    ]
    type = 'row(id varchar, logins array(varchar), onemore varchar)'
    expected_value = {
      'id' => 'userId',
      'logins' => %w[userLogin1 userLogin2],
      'onemore' => 'value'
    }
    expect(column_value(data, type)).to eq(expected_value)
  end

  it 'parses row type values that have a row in them' do
    data = [
      'userId',
      ['userLogin', '2022-07-01T14:53:02Z', 1234],
      'value'
    ]
    type = 'row(id varchar, subobj row(login varchar, created_at timestamp with time zone, id integer), onemore varchar)'
    expected_value = {
      'id' => 'userId',
      'subobj' => {
        'login' => 'userLogin',
        'created_at' => Time.parse('2022-07-01T14:53:02Z'),
        'id' => 1234
      },
      'onemore' => 'value'
    }
    value = column_value(data, type)
    expect(column_value(data, type)).to eq(expected_value)
    expect(value['subobj']['created_at'].is_a?(Time)).to eq true
  end

  it 'parses row type values that have nested rows in them' do
    data = [
      'userId',
      ['userLogin', '2022-07-01T14:53:02Z', [1234]],
      'value'
    ]
    type = 'row(id varchar, subobj row(login varchar, created_at timestamp with time zone, id row(subid integer)), onemore varchar)'
    expected_value = {
      'id' => 'userId',
      'subobj' => {
        'login' => 'userLogin',
        'created_at' => Time.parse('2022-07-01T14:53:02Z'),
        'id' => { 'subid' => 1234 }
      },
      'onemore' => 'value'
    }
    value = column_value(data, type)
    expect(column_value(data, type)).to eq(expected_value)
    expect(value['subobj']['created_at'].is_a?(Time)).to eq true
  end
end
