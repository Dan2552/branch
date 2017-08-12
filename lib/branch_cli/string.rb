class String
  def matches(forRegex: nil)
    lines = split("\n")
    lines.map do |l|
      match = l.match(forRegex)
      match && match.captures
    end.flatten.compact
  end

  def clearQuotes
    gsub("\"", with: "")
  end

  def s
    self
  end

  def Bold
    "[bold]#{self}[/]"
  end

  def f
    self
  end

  def Green
    "[green]#{self}[/]"
  end

  def Blue
    "[blue]#{self}[/]"
  end

  def Red
    "[red]#{self}[/]"
  end

  def Yellow
    "[yellow]#{self}[/]"
  end

  def Purple
    "[purple]#{self}[/]"
  end

  def LightPurple
    "[light_purple]#{self}[/]"
  end

  def Cyan
    "[cyan]#{self}[/]"
  end
end
