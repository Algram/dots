final: prev:

let
  py = prev.python313Packages;

  aiosendspin = py.buildPythonPackage {
    pname = "aiosendspin";
    version = "3.0.0";

    src = prev.fetchFromGitHub {
      owner = "Sendspin";
      repo = "aiosendspin";
      rev = "main";
      sha256 = "sha256-YgqfMoathHyFeKD6Io0hc6goj8lgADE4qWJ7GaT/3RY=";
    };

    # pyproject = true;
    # nativeBuildInputs = with py; [ setuptools wheel ];
    # propagatedBuildInputs = with py; [ numpy aioconsole sounddevice ];
    # buildInputs = [ prev.portaudio ];
    # doCheck = false;
    # dontCheckRuntimeDeps = true;

    # do not run tests
    doCheck = false;

    # specific to buildPythonPackage, see its reference
    pyproject = true;
    build-system = with py; [ setuptools wheel ];
    propagatedBuildInputs = with py; [
      aiohttp
      av
      mashumaro
      orjson
      pillow
      zeroconf
    ];
  };

  mpris-api = py.buildPythonPackage {
    pname = " mpris-api";
    version = "2.1.0";

    src = prev.fetchFromBitbucket {
      owner = "massultidev";
      repo = "mpris-api";
      rev = "master";
      sha256 = "sha256-MzeJIPPZkOQSsytNaETRZC9WwQflYzcL4TG705N7pEg=";
    };

    # pyproject = true;
    # nativeBuildInputs = with py; [ setuptools wheel ];
    # propagatedBuildInputs = with py; [ numpy aioconsole sounddevice ];
    # buildInputs = [ prev.portaudio ];
    # doCheck = false;
    # dontCheckRuntimeDeps = true;

    # do not run tests
    doCheck = false;

    # specific to buildPythonPackage, see its reference
    pyproject = true;
    build-system = with py; [ setuptools wheel ];
    propagatedBuildInputs = [
      # py.aiohttp
      py.av
      # py.mashumaro
      # py.orjson
      # py.pillow
      # py.zeroconf
      # # py.mpris-api
      # aiosendspin
    ];

    # dontCheckRuntimeDeps = true;
  };

  aiosendspin-mpris = py.buildPythonPackage {
    pname = " aiosendspin-mpris";
    version = "2.1.0";

    src = prev.fetchFromGitHub {
      owner = "abmantis";
      repo = "aiosendspin-mpris";
      rev = "main";
      sha256 = "sha256-MzeJIPGZkOQSsytNaETRZC9WwQflYzcL4TG705N7pEg=";
    };

    # pyproject = true;
    # nativeBuildInputs = with py; [ setuptools wheel ];
    # propagatedBuildInputs = with py; [ numpy aioconsole sounddevice ];
    # buildInputs = [ prev.portaudio ];
    # doCheck = false;
    # dontCheckRuntimeDeps = true;

    # do not run tests
    doCheck = false;

    # specific to buildPythonPackage, see its reference
    pyproject = true;
    build-system = with py; [ setuptools wheel ];
    propagatedBuildInputs = [
      py.aiohttp
      py.av
      py.mashumaro
      py.orjson
      py.pillow
      py.zeroconf
      # py.mpris-api
      aiosendspin
    ];

    dontCheckRuntimeDeps = true;
  };

in {
  sendspin-cli = py.buildPythonApplication {
    pname = "sendspin-cli";
    version = "4.0.0";

    src = prev.fetchFromGitHub {
      owner = "Sendspin";
      repo = "sendspin-cli";
      rev = "main";
      sha256 = "sha256-9OLUWbhe8xWlVV2ot74DPlpqZZSB+7WMLJk9vydJa2w=";
    };

    pyproject = true;
    nativeBuildInputs = with py; [ setuptools wheel ];

    # ✅ explicitly reference the already-built aiosendspin
    propagatedBuildInputs = [
      py.aioconsole
      aiosendspin-mpris
      py.sounddevice
      aiosendspin
      py.qrcode
      py.readchar
      py.rich
    ];

    buildInputs = [ prev.portaudio ];

    dontCheckRuntimeDeps = true;
  };
}
