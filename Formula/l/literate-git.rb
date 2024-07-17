class LiterateGit < Formula
  include Language::Python::Virtualenv

  desc "Render hierarchical git repositories into HTML"
  homepage "https://github.com/bennorth/literate-git"
  url "https://files.pythonhosted.org/packages/7f/eb/b9798ba7c4e818b26b7214dff2bd43d4ec58c8dab956e5d71e9b5549b099/literategit-0.4.8.tar.gz"
  sha256 "4dbbaf08a6db02d8a1076e3ef54ea046bd297b47abadd06c35812a4ca2aff8a1"
  license "GPL-3.0-or-later"

  bottle do
    sha256 cellar: :any,                 arm64_sonoma:   "dc3bb7409c8a14d06f16ca896b49b17c7549d217b8b809a5a13a5f99aae12ea1"
    sha256 cellar: :any,                 arm64_ventura:  "cb1aa2bd7f1dc350ff3e7bff5f47784725ee24cf1bcd20d829fdfb43b29a1183"
    sha256 cellar: :any,                 arm64_monterey: "daeff0fffe9d17ba3e4513faa7825d3b2a828fe66bdf537d130ab9faa30e62e1"
    sha256 cellar: :any,                 sonoma:         "f9190d897e5a7fe7e8abd0cc614925562db1eaa46c0aafa349669633546c8601"
    sha256 cellar: :any,                 ventura:        "56b6d56dee84f57f9030863a1566b1a3eac5912e540bd13e8c6db145a691e6df"
    sha256 cellar: :any,                 monterey:       "dbff94779ed3ffe9008b072f794854bc9da4f36ac47f88e43defc3524374711d"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "58fd27c6a6b014e312352d54e0972ec39c1f3b11f0eca601fe12fd0bccc618c9"
  end

  depends_on "libgit2"
  depends_on "python@3.12"

  uses_from_macos "libffi"

  on_linux do
    depends_on "pkg-config" => :build
  end

  resource "cffi" do
    url "https://files.pythonhosted.org/packages/68/ce/95b0bae7968c65473e1298efb042e10cafc7bafc14d9e4f154008241c91d/cffi-1.16.0.tar.gz"
    sha256 "bcb3ef43e58665bbda2fb198698fcae6776483e0c4a631aa5647806c25e02cc0"
  end

  resource "click" do
    url "https://files.pythonhosted.org/packages/96/d3/f04c7bfcf5c1862a2a5b845c6b2b360488cf47af55dfa79c98f6a6bf98b5/click-8.1.7.tar.gz"
    sha256 "ca9853ad459e787e2192211578cc907e7594e294c7ccc834310722b41b9ca6de"
  end

  resource "jinja2" do
    url "https://files.pythonhosted.org/packages/ed/55/39036716d19cab0747a5020fc7e907f362fbf48c984b14e62127f7e68e5d/jinja2-3.1.4.tar.gz"
    sha256 "4a3aee7acbbe7303aede8e9648d13b8bf88a429282aa6122a993f0ac800cb369"
  end

  resource "markdown2" do
    url "https://files.pythonhosted.org/packages/da/00/3c708de5bffa0494daf894d2e8e2b6165f866ef3ae7939546fae039b5f0e/markdown2-2.5.0.tar.gz"
    sha256 "9bff02911f8b617b61eb269c4c1a5f9b2087d7ff051604f66a61b63cab30adc2"
  end

  resource "markupsafe" do
    url "https://files.pythonhosted.org/packages/87/5b/aae44c6655f3801e81aa3eef09dbbf012431987ba564d7231722f68df02d/MarkupSafe-2.1.5.tar.gz"
    sha256 "d283d37a890ba4c1ae73ffadf8046435c76e7bc2247bbb63c00bd1a709c6544b"
  end

  resource "pycparser" do
    url "https://files.pythonhosted.org/packages/1d/b2/31537cf4b1ca988837256c910a668b553fceb8f069bedc4b1c826024b52c/pycparser-2.22.tar.gz"
    sha256 "491c8be9c040f5390f5bf44a5b07752bd07f56edf992381b05c701439eec10f6"
  end

  resource "pygit2" do
    url "https://files.pythonhosted.org/packages/53/77/d33e2c619478d0daea4a50f9ffdd588db2ca55817c7e9a6c796fca3b80ef/pygit2-1.15.1.tar.gz"
    sha256 "e1fe8b85053d9713043c81eccc74132f9e5b603f209e80733d7955eafd22eb9d"
  end

  resource "pygments" do
    url "https://files.pythonhosted.org/packages/8e/62/8336eff65bcbc8e4cb5d05b55faf041285951b6e80f33e2bff2024788f31/pygments-2.18.0.tar.gz"
    sha256 "786ff802f32e91311bff3889f6e9a86e81505fe99f2735bb6d60ae0c5004f199"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    system "git", "init"
    (testpath/"foo.txt").write "Hello"
    system "git", "add", "foo.txt"
    system "git", "commit", "-m", "foo"
    system "git", "branch", "one"
    (testpath/"bar.txt").write "World"
    system "git", "add", "bar.txt"
    system "git", "commit", "-m", "bar"
    system "git", "branch", "two"
    (testpath/"create_url.py").write <<~EOS
      class CreateUrl:
        @staticmethod
        def result_url(sha1):
          return ''
        @staticmethod
        def source_url(sha1):
          return ''
    EOS
    assert_match "<!DOCTYPE html>",
      shell_output("git literate-render test one two create_url.CreateUrl")
  end
end
