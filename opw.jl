#!/usr/local/bin/julia -q --color=yes


dataFile = Pkg.dir(homedir(), ".jonepw.jls")

save(data) = begin
  open(f->serialize(f, data), dataFile, "w")
end

load() = begin
  open(deserialize, dataFile)
end

type Onepw
  id::AbstractString
  tag::AbstractString
  pwd::AbstractString
end

if !isfile(dataFile)
  onepw = Onepw[]
  save(onepw)
end

onepw = load()

align(str, len) = begin
  spaces = repeat(" ", len - length(str))
  return "$str$spaces"
end

ls(args) = begin
  for item in onepw
    println("$(align(item.id, 16))$(align(item.tag, 16))$(align(item.pwd, 32))")
  end
end

rm(args) = begin
  for (i, item) in enumerate(onepw)
    if args[1] == item.id
      splice!(onepw, i)
    end
  end
  ls([])
  save(onepw)
end

add(args) = begin
  id = num2hex(time())[9:end]
  push!(onepw, Onepw(id, args[1], args[2]))
  ls([])
  save(onepw)
end

gen(args) = begin
  println(randstring(parse(Int, args[1])))
end

usage(args) = begin
  str = """
    ls  => list
    rm  => remove
    add => add
    gen => generate
  """
  
  println(str)
end

handler = Dict(
  "ls"  => ls,
  "rm"  => rm,
  "add" => add,
  "gen" => gen
)

main() = begin
  if length(ARGS) == 0
    ls([])
  else
    get(handler, ARGS[1], usage)(ARGS[2:end])
  end
end

main()
