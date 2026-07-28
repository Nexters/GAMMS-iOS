require 'xcodeproj'

args = ARGV.dup
is_resource = args.delete('--resource') ? true : false
target_name = args.shift
file_paths = args

raise 'Usage: ruby Tools/xcode_add_files.rb <target_name> <file1> [file2 ...] [--resource]' if target_name.nil? || file_paths.empty?

project = Xcodeproj::Project.open('GAMSS.xcodeproj')
target = project.targets.find { |t| t.name == target_name }
raise "Target not found: #{target_name}" unless target

def find_or_create_group(root_group, group_path)
  return root_group if group_path.nil? || group_path.empty? || group_path == '.'

  group_path.split('/').reduce(root_group) do |parent, component|
    child = parent.children.find { |c| c.isa == 'PBXGroup' && c.display_name == component }
    child || parent.new_group(component, component)
  end
end

file_paths.each do |file_path|
  raise "File does not exist on disk: #{file_path}" unless File.exist?(file_path)

  group_path = File.dirname(file_path)
  group = find_or_create_group(project.main_group, group_path)
  group.set_source_tree('<group>')

  file_name = File.basename(file_path)
  file_ref = group.files.find { |f| f.path == file_name } || group.new_reference(file_name)

  if is_resource
    target.add_resources([file_ref])
  else
    target.add_file_references([file_ref])
  end
end

project.save
kind = is_resource ? 'resources' : 'sources'
puts "Added #{file_paths.join(', ')} to #{target_name} (#{kind})"
