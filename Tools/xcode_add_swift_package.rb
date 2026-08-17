require 'xcodeproj'

target_name, repo_url, min_version, product_name = ARGV
if [target_name, repo_url, min_version, product_name].any?(&:nil?)
  raise 'Usage: ruby Tools/xcode_add_swift_package.rb <target_name> <repo_url> <min_version> <product_name>'
end

project = Xcodeproj::Project.open('GAMSS.xcodeproj')
target = project.targets.find { |t| t.name == target_name }
raise "Target not found: #{target_name}" unless target

package_ref = project.root_object.package_references.find do |ref|
  ref.respond_to?(:repositoryURL) && ref.repositoryURL == repo_url
end
unless package_ref
  package_ref = project.new(Xcodeproj::Project::Object::XCRemoteSwiftPackageReference)
  package_ref.repositoryURL = repo_url
  package_ref.requirement = { 'kind' => 'upToNextMajorVersion', 'minimumVersion' => min_version }
  project.root_object.package_references << package_ref
end

already_linked = target.package_product_dependencies.any? { |dep| dep.product_name == product_name }
unless already_linked
  product_dependency = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
  product_dependency.package = package_ref
  product_dependency.product_name = product_name
  target.package_product_dependencies << product_dependency

  build_file = project.new(Xcodeproj::Project::Object::PBXBuildFile)
  build_file.product_ref = product_dependency
  target.frameworks_build_phase.files << build_file
end

project.save
puts "Added #{product_name} (#{repo_url}) to #{target_name}"
