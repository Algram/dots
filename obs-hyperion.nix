{ stdenv, lib, fetchFromGitHub, cmake, wrapQtAppsHook, flatbuffers, git
, obs-studio, qtbase
}:

stdenv.mkDerivation rec {
  pname = "obs-hyperion";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "hyperion-project";
    repo = "hyperion-obs-plugin";
    rev = "${version}";
    sha256 = "sha256-QYKqMGwslnIV0nMbjSOCH82U8Ny8bqAyNt/4UCX27MM=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake wrapQtAppsHook flatbuffers git];
  buildInputs = [ obs-studio qtbase flatbuffers git];

  cmakeFlags = [
    "-DOBS_SOURCE=${obs-studio.src}"
    "-DFLATBUFFERS_FLATC_EXECUTABLE=${flatbuffers}/bin/flatc"
    "-DGLOBAL_INSTALLATION=ON"
  ];

  # buildPhase = ''
  #   export HOME=$(pwd)
  # '';

  # installPhase = ''
  #   export HOME=$(pwd)
  # '';


  meta = with lib; {
    description = "OBS Studio source plugin for NVIDIA FBC API";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ babbaj ];
    platforms = [ "x86_64-linux" ];
  };
}
