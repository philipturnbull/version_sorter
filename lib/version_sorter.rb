module VersionSorter
  def self.sort(versions, &blk)
    self.sort!(versions.dup, &blk)
  end

  def self.sort!(versions, &blk)
    self.do_sort!(versions, 1, &blk)
    versions
  end

  def self.rsort(versions, &blk)
    self.rsort!(versions.dup, &blk)
  end

  def self.rsort!(versions, &blk)
    self.do_sort!(versions, -1, &blk)
    versions
  end

  def self.do_sort!(versions, mult, &blk)
    versions.map! { |v| [v, self.parse_version_number(v, &blk)] }
    versions.sort! { |(_, a), (_, b)| self.compare_comps(a, b) * mult }
    versions.map! { |(v, _)| v }
  end

  def self.compare(a, b)
    self.compare_comps(self.parse_version_number(a), self.parse_version_number(b))
  end

  def self.compare_comps(a, b)
    max_n = [a.length, b.length].min

    n = 0
    while n < max_n
      if a[n].class == b[n].class
        if a[n].class == Integer
          cmp = a[n] <=> b[n]
        else
          len = [a[n].length, b[n].length].min
          cmp = a[n][0...len] <=> b[n][0...len]
          if cmp == 0
            cmp = a[n].length <=> b[n].length
          end
        end
        if cmp != 0
          return cmp
        end
      else
        return a[n].class == Integer ? 1 : -1
      end
      n += 1
    end

    if a.length < b.length
      b[n].class == Integer ? -1 : 1
    elsif b.length < a.length
      a[n].class == Integer ? 1 : -1
    else
      0
    end
  end

  def self.parse_version_number(string, &blk)
    if blk
      string = blk.call(string)
    end

    comps = []
    offset = 0
    while offset < string.length && comps.length < 64
      if string[offset] =~ /[0-9]/
        number = 0
        start = offset
        overflown = false

        while string[offset] =~ /[0-9]/
          if !overflown
            number = (10 * number) + (string[offset].ord - ?0.ord)
            if number >= 2 ** 32
              number -= 2 ** 32
              overflown = true
            end
          end

          offset += 1
        end

        if overflown
          comps << string[start...offset]
        else
          comps << number
        end
      elsif string[offset] =~ /[a-zA-Z-]/
        start = offset
        offset += 1 if string[offset] == "-"
        offset += 1 while string[offset] =~ /[a-zA-Z]/
        comps << string[start...offset]
      else
        offset += 1
      end
    end
    comps
  end
end
