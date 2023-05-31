{
  beam,
  stdenv,
  rustPlatform,
  rustc,
  glibcLocales,
  cargo,
  gmp6,
  automake,
  libtool,
  inotify-tools,
  autoconf,
  gcc,
  libiconv,
  initD2N,
  src
}: let

  libsecp256k1 = builtins.fetchTree {
    type = "github";
    owner = "bitcoin";
    repo = "secp256k1";
    rev = "d33352151699bd7598b868369dace092f7855740";
    narHash = "sha256-fpOtL59tzAk3tHU6gNVCIBcdIKojwp2soWUu591L4ko=";
  };

  # The blockscout application. This is an elixir application (BEAM). It comes
  # with it's own frontend in javascript (built via npm).  There are two
  # significant complications with this application:
  # - the ex_keccak library uses rustler to build rust code *while* it is
  #   being built. This requires a bit of working around cargo wanting to
  #   download and connect to the internet during the build. Luckily we can
  #   re-use some of the rust infrastructure for this to pre-download
  #   the rust dependencies and make them available.
  # - the secp256k1 library tries similarly to pull a copy of secp256k1 from
  #   github during build. This has similiar implication, and needs some
  #   workarounds.
  beamPkgs = beam.packagesWith beam.interpreters.erlang;

  # To build the blockscout assets (via npm and webpack), we need to prepare the
  # lock file a bit, as it contains relative paths of its host repo. So we need
  # to copy in the javascript packages embedded in the elixir package
  # (phoenix, phoenix_html).
  blockscout-assets-src = stdenv.mkDerivation {
    inherit src;

    pname = "blockscout-assets-src";
    version = "0.0.0";
    buildPhase = "";
    installPhase = ''
      cp -r $src/apps/block_scout_web/assets/ $out
      chmod +w $out
      chmod +w $out/package-lock.json
      # Fix relative path dependencies from host repo
      sed -i.bck 's|../../../deps|deps|g' $out/package-lock.json
      sed -i.bck 's|../../../deps|deps|g' $out/package.json
      mkdir -p $out/deps
      chmod -R +w $out/deps
      cp -r ${mixFodDeps}/phoenix      $out/deps/
      cp -r ${mixFodDeps}/phoenix_html $out/deps/
      cd $out
    '';
  };
  blockscout-d2n =
    (initD2N.makeOutputs {
      source = "${blockscout-assets-src}";
      packageOverrides = {
        blockscout = {
          fix-webpack-excludes = {
            postPatch = ''
              substituteInPlace ./webpack.config.js \
                --replace "exclude: /node_modules/" \
                          "exclude: path.join(__dirname, 'node_modules')"
            '';
          };
          install = {
            installPhase = "mv ../priv $out";
          };
        };
      };
    })
    .packages
    .blockscout;

  # We need two extra rebar3 plugins that are used by the blockscout app.  So
  # we'll pull them via flakes and add them via rebar3WithPackages.
  rebar3_hex = beamPkgs.buildRebar3 {
    name = "rebar3_nix";
    version = "0.1.1";
    src = builtins.fetchTree {
      type = "github";
      owner = "erlef";
      repo = "rebar3_hex";
      ref = "v7.0.2";
      narHash = "sha256-7bgxf69kq6E4QvemAPruPMcZZC5UJ5niCoYN3KjaHkU=";
    };
  };
  rebar3_archive_plugin = beamPkgs.buildRebar3 {
    name = "rebar3_archive_plugin";
    version = "0.0.2";
    src = builtins.fetchTree {
      type = "github";
      owner = "deadtrickster";
      repo = "rebar3_archive_plugin";
      ref = "v0.0.2";
      narHash = "sha256-oDcFbZ8XXGtRNCDRhnyLjYJ+r5Bbvi+eDc0xOl9MdLs=";
    };
  };

  mixFodDeps = beamPkgs.fetchMixDeps {
    inherit src;
    pname = "blockscout-deps";
    version = "0.0.1";
    sha256 = "sha256-DGdjJ1HAtvd51F4b1bWLzM9q2ZORFA6Zza5ajah+3vg=";
  };
in
  (beamPkgs.mixRelease {
    inherit mixFodDeps src;

    pname = "blockscout";
    version = "0.0.0";

    RELEASE_DISTRIBUTION = "none";
    LANG = "C.UTF-8";

    cargoDeps = rustPlatform.fetchCargoTarball {
      src = mixFodDeps;
      sourceRoot = "blockscout-deps-0.0.1/ex_keccak/native/exkeccak";
      sha256 = "sha256-IxeZhqxg0k9CX2K+tNKBWPZhD29DKUfaDhmCFST9LQ4=";
    };
    nativeBuildInputs = [
      # these are needed for exkeccak
      rustc
      glibcLocales
      cargo
      rustPlatform.cargoSetupHook
      # these are needed for the libsecp256k1
      gmp6
      automake
      libtool
      inotify-tools
      autoconf
      gcc
      libiconv
    ];

    postUnpack =
      # this is needed for the rustler/cargo logic for exkeccack so that the
      # cargoSetupHook unpacking doesn't complain. And subsequently the necessary
      # rust+cargo env vars are set for the cargo build of exkeccack to succeed.
      ''
        cp ${mixFodDeps}/ex_keccak/native/exkeccak/Cargo.lock $sourceRoot/
      ''
      +
      # This one we need for libsecp256k1.  The build_deps file is called from
      # make, and thus needs to be executable.  We also needt the libsecp256k1
      # source (we pull in via a flake input), to build it from source.  The
      # libsecp256k1 needs to be writable as we are (facepalm) building sofware
      # in place.
      ''
        chmod +x $MIX_DEPS_PATH/libsecp256k1/c_src/build_deps.sh
        sed -i.bck 's/git /true /' $MIX_DEPS_PATH/libsecp256k1/c_src/build_deps.sh
        cp -r ${libsecp256k1} $MIX_DEPS_PATH/libsecp256k1/c_src/secp256k1
        chmod +w -R $MIX_DEPS_PATH/libsecp256k1/c_src/secp256k1
      ''
      +
      # This is needed to make (mix release) at least not fail. It still doesn't
      # work though; as it's not something that seems well supported in
      # blockscout
      ''
        sed -i.bck 's/:block_scout/:explorer/g' $sourceRoot/mix.exs
      ''
      +
      # We need to fix the CREATE EXTENSION into one that is idempotent.
      ''
        sed -i.bck 's/CREATE EXTENSION/CREATE EXTENSION IF NOT EXISTS/g' \
          $sourceRoot/apps/explorer/priv/repo/migrations/20190403080447_add_full_text_search_tokens.exs
      ''
      +
      # We also need mamba in the production environment
      ''
        cp $sourceRoot/apps/explorer/config/dev/mamba.exs $sourceRoot/apps/explorer/config/prod/mamba.exs
      '';

    postBuild = ''
      # This would be the npm build step in the block_scout_web application.
      # We had to build this outside, and now copy the static folder produced
      # by webpack into the build directory.
      cp -r ${blockscout-d2n}/priv/static apps/block_scout_web/priv/
      chmod +w -R apps/block_scout_web/priv/static

      # for external task you need a workaround for the no deps check flag
      # https://github.com/phoenixframework/phoenix/issues/2690
      mix do deps.loadpaths --no-deps-check, phx.digest
    '';

    installPhase = let
      hex = beamPkgs.hex.name;
    in ''
      runHook preInstall
      # It appears blockscout doesn't have a proper release phase, and as such
      # we'll have to rely on the source.
      cd ..
      mkdir $out
      mv $sourceRoot $out/
      mv $MIX_DEPS_PATH $out/
      mkdir -p $out/.mix/archives/${hex}
      ln -s ${beamPkgs.hex}/lib/erlang/lib/hex $out/.mix/archives/${hex}/${hex}
      mkdir -p $out/bin


      # We use this launcher, instead of whatever mix release produces,
      # because we want to run ecto create and migrate as well. And the
      # release logic for (mix release), is just not properly developped
      # in blockscout
      cat << EOF > $out/bin/blockscout
      export PATH=${beamPkgs.elixir}/bin:$PATH
      export MIX_DEPS_PATH=$out/deps
      export MIX_ENV=prod
      export MIX_HOME=$out/.mix

      cd $out/source
      exec -a "\$0" mix "do" deps.loadpaths --no-deps-check, \\
               ecto.create    --no-compile  --no-deps-check, \\
               ecto.migrate   --no-compile  --no-deps-check, \\
               phx.server     --no-compile
      EOF
      chmod +x $out/bin/blockscout
      runHook postInstall
    '';

    passthru = {inherit beamPkgs rebar3_hex;};
  })
  .overrideAttrs (_: {
    # Having to set this here is ... just stupid; but, oh well.
    MIX_REBAR3 = "${beamPkgs.rebar3WithPlugins {globalPlugins = [beamPkgs.pc beamPkgs.rebar3-nix rebar3_hex rebar3_archive_plugin];}}/bin/rebar3";
  })
