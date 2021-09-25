def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone")

def parse_dns(dns_raw)
  dns_data = []
  dns_raw.map.with_index{
    |data, i| dns_data[i] = data.strip.split(", ")
  }
  dns_records = Hash.new{|info, key| info[key] = {} }

  dns_data.map.with_index{
    |value, i|
    result = value[1].to_s

    dns_records[result][:type] = value[0]
    dns_records[result][:target] = value[2]
  }
  return dns_records
end

def resolve(dns_records, lookup_chain, domain)
  if dns_records[domain][:type] == "A"
    lookup_chain.push(dns_records[domain][:target])
  elsif dns_records[domain][:type] == "CNAME"
    lookup_chain.push(dns_records[domain][:target])
    resolve(dns_records, lookup_chain, dns_records[domain][:target])
  else
    lookup_chain.delete(domain)
    lookup_chain.push("Error: record not found for #{domain}")
  end
  return lookup_chain
end

# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
