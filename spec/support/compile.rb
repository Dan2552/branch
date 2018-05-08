def compile
  root = File.expand_path("..", __dir__)
  system("cd #{root} && docker-compose run compile")
end
