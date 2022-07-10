defmodule NervesLivebook.DependenciesTest do
  use ExUnit.Case, async: true
  alias NervesLivebook.Dependencies

  defp all_package_names() do
    for %{name: name} <- Dependencies.packages(), do: name
  end

  test "returns reasonable number of packages" do
    packages = Dependencies.packages()

    assert Enum.count(packages) > 50
  end

  test "returns some nerves-related packages" do
    names = all_package_names()
    assert "circuits_i2c" in names
    assert "circuits_spi" in names
    assert "circuits_uart" in names

    if Application.fetch_env!(:nerves_runtime, :target) != "host" do
      assert "vintage_net" in names
      assert "vintage_net_wifi" in names
    end
  end

  test "packages are alphabetized" do
    names = all_package_names()
    resorted = Enum.sort(names)

    assert names == resorted
  end

  test "does not return OTP libraries" do
    names = all_package_names()
    refute "kernel" in names
    refute "stdlib" in names
    refute "ssh" in names
    refute "ssl" in names
    refute "crypto" in names
  end

  test "does not return nerves_livebook" do
    names = all_package_names()
    refute "nerves_livebook" in names
  end

  test "version numbers all parse" do
    packages = Dependencies.packages()

    for %{dependency: {name, requirement}, version: version} <- packages do
      assert {:ok, _} = Version.parse(version), "expected #{version} to parse for #{name}"

      assert {:ok, _} = Version.parse_requirement(requirement),
             "expected #{requirement} to parse for #{name}"

      assert Version.match?(version, requirement),
             "expected #{version} to work with #{requirement} for #{name}"
    end
  end

  @tag slow: true
  test "urls all work" do
    packages = Dependencies.packages()

    for %{name: name, url: url} <- packages do
      response = Req.get!(url)
      assert response.status == 200, "expected #{url} to work for #{name}"
    end
  end
end
