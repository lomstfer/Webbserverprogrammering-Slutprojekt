def all_of(*strings)
    return /(#{strings.join("|")})/
end