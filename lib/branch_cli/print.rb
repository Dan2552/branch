def prettyPrint(str)
  printer = Formatador.new
  printer.instance_eval { @indent = 0 }
  printer.display_line(str.strip)
end
