#!/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'json'
require 'pathname'
require 'pry'

pathname = Pathname.new ARGV.first
raise "No such file #{pathname}" unless pathname.exist?

csv = CSV.table(pathname)

class Wikidate
  METHODS = {
    11 => 'day',
    10 => 'month',
    9  => 'year',
    8  => 'decade',
  }.freeze

  def initialize(datestr, precision)
    @datestr   = datestr
    @precision = precision
  end

  def to_s
    send(method)
  end

  private

  attr_reader :datestr, :precision

  def method
    METHODS[precision] or raise("Unknown precision: #{precision}")
  end

  def day
    datestr[0...10]
  end

  def month
    datestr[0...7]
  end

  def year
    datestr[0...4]
  end

  def decade
    "#{datestr[0...3]}0s"
  end
end

class Member
  def initialize(row)
    @row = row
  end

  def to_h
    {
      name:        name,
      gender:      gender,
      birth_date:  birth_date,
      identifiers: [{ identifier: id, scheme: 'wikidata.org' }],
      other_names: other_names,
      sources:     [{ url: source }],
    }.compact
  end

  private

  attr_reader :row

  def name
    row[:name]
  end

  def gender
    row[:gender]
  end

  def birth_date
    return unless dob_precision

    Wikidate.new(dob, dob_precision).to_s
  end

  def dob
    row[:dob]
  end

  def dob_precision
    row[:dobprecision]
  end

  def id
    row[:item]
  end

  def other_names
    return if name == label

    [{ name: label, source: 'wikidata.org' }]
  end

  def label
    row[:enlabel]
  end

  def source
    row[:source]
  end
end

data = {
  body: {
    id:   'Q515426',
    name: 'Texas Senate',
    term: {
      id:      'Q104767030',
      name:    '87th Texas Legislature',
      members: csv.map { |row| Member.new(row).to_h },
    },
  },
}

puts JSON.pretty_generate(data)
