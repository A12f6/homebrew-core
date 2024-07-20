class Cryptography < Formula
  desc "Cryptographic recipes and primitives for Python"
  homepage "https://cryptography.io/en/latest/"
  url "https://files.pythonhosted.org/packages/69/ec/9fb9dcf4f91f0e5e76de597256c43eedefd8423aa59be95c70c4c3db426a/cryptography-43.0.0.tar.gz"
  sha256 "b88075ada2d51aa9f18283532c9f60e72170041bba88d7f37e49cbb10275299e"
  license any_of: ["Apache-2.0", "BSD-3-Clause"]
  head "https://github.com/pyca/cryptography.git", branch: "main"

  bottle do
    sha256 cellar: :any,                 arm64_sonoma:   "634346cb47bbcf97c61c968f5dbdb8e20cfa61e105bccaa64bc4d77686a905c9"
    sha256 cellar: :any,                 arm64_ventura:  "6857c224dd8cada92edb85cfebd190f7750ecd340ffc0a771582928a67a97df9"
    sha256 cellar: :any,                 arm64_monterey: "1b7a356f952ec1fae8e8f5841baf21886cf2e5819ec4a11a5244dbf321c4038e"
    sha256 cellar: :any,                 sonoma:         "f849e69b449bb7fefa0d30a3418df38731646027f8eef135a357f3adfd4dc5d1"
    sha256 cellar: :any,                 ventura:        "c2f40add6226a6f7bfc14a9a4001053349f6ef7f97db1cfcfe139b84686cb3dd"
    sha256 cellar: :any,                 monterey:       "cc3c59c05f5ff7d76932f4ad31053298afa0dd56d51e532910f3911c44d22150"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "f82da8a29e4dfcfd6740a347ff6f2fbc3ddea6bec7db175b89c99dbf54ea0975"
  end

  depends_on "maturin" => :build
  depends_on "pkg-config" => :build
  depends_on "python@3.11" => [:build, :test]
  depends_on "python@3.12" => [:build, :test]
  depends_on "rust" => :build
  depends_on "cffi"
  depends_on "openssl@3"

  resource "semantic-version" do
    url "https://files.pythonhosted.org/packages/7d/31/f2289ce78b9b473d582568c234e104d2a342fd658cc288a7553d83bb8595/semantic_version-2.10.0.tar.gz"
    sha256 "bdabb6d336998cbb378d4b9db3a4b56a1e3235701dc05ea2690d9a997ed5041c"
  end

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/b2/9b/c154d7694227ff8f5ee5bdff2f8cf8a529ba8f53e80806dd984737c59b19/setuptools-71.0.4.tar.gz"
    sha256 "48297e5d393a62b7cb2a10b8f76c63a73af933bd809c9e0d0d6352a1a0135dd8"
  end

  resource "setuptools-rust" do
    url "https://files.pythonhosted.org/packages/9d/f1/2cb8887cad0726a5e429cc9c58e30767f58d22c34d55b075d2f845d4a2a5/setuptools-rust-1.9.0.tar.gz"
    sha256 "704df0948f2e4cc60c2596ad6e840ea679f4f43e58ed4ad0c1857807240eab96"
  end

  resource "maturin" do
    url "https://files.pythonhosted.org/packages/80/da/a4bbd6e97f3645f4ebd725321aa235e22e31037dfd92caf4539f721c0a5a/maturin-1.7.0.tar.gz"
    sha256 "1ba5277dd7832dc6181d69a005182b97b3520945825058484ffd9296f2efb59c"
  end

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.start_with?("python@") }
        .map { |f| f.opt_libexec/"bin/python" }
  end

  def install
    pythons.each do |python3|
      ENV.append_path "PYTHONPATH", buildpath/Language::Python.site_packages(python3)

      resources.each do |r|
        r.stage do
          system python3, "-m", "pip", "install", *std_pip_args(prefix: buildpath), "."
        end
      end

      system python3, "-m", "pip", "install", *std_pip_args, "."
    end
  end

  test do
    (testpath/"test.py").write <<~EOS
      from cryptography.fernet import Fernet
      key = Fernet.generate_key()
      f = Fernet(key)
      token = f.encrypt(b"homebrew")
      print(f.decrypt(token))
    EOS

    pythons.each do |python3|
      assert_match "b'homebrew'", shell_output("#{python3} test.py")
    end
  end
end
