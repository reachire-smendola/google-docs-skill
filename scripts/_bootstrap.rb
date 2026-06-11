# frozen_string_literal: true

# Bootstrap vendored gem paths so scripts work with plain `ruby`,
# without requiring `bundler` to be installed or on PATH.
#
# Assumes gems were vendored via `bundle install` into `vendor/bundle/`
# and respects the `GOOGLE_SKILL_CONFIG_DIR` (or BUNDLE_PATH) convention.

def bootstrap_vendored_gems!(skill_root: nil)
  # Already bootstrapped? Skip.
  return if defined?(@_vendored_gems_bootstrapped)

  skill_root ||= File.expand_path('..', __dir__)
  vendor_root = File.join(skill_root, 'vendor', 'bundle')

  return unless Dir.exist?(vendor_root)

  ruby_engine = defined?(RUBY_ENGINE) ? RUBY_ENGINE : 'ruby'

  # Bundler stores gems under vendor/bundle/<engine>/<abi_version>/gems/
  # Try the current Ruby version first, then fall back to any existing directory
  version_dir = File.join(vendor_root, ruby_engine)

  return unless Dir.exist?(version_dir)

  Dir.entries(version_dir).sort.reverse_each do |subdir|
    next if subdir.start_with?('.')

    gem_dir = File.join(version_dir, subdir, 'gems')
    next unless Dir.exist?(gem_dir)

    Dir.glob(File.join(gem_dir, '*', 'lib')).each { |lib| $LOAD_PATH.unshift(lib) }
    break # use the first (newest) matching version
  end

  @_vendored_gems_bootstrapped = true
end

bootstrap_vendored_gems!
