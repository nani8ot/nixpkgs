{ stdenv
, lib
, fetchurl
, pkg-config
, gettext
, gobject-introspection
, wrapGAppsHook
, gjs
, glib
, gtk4
, gdk-pixbuf
, gst_all_1
, gnome
, meson
, ninja
, python3
, desktop-file-utils
, libadwaita
}:

stdenv.mkDerivation rec {
  pname = "gnome-sound-recorder";
  version = "43.beta";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${lib.versions.major version}/${pname}-${version}.tar.xz";
    sha256 = "bbbbmjsbUv0KtU+aW/Tymctx5SoTrF/fw+dOtGmFpOY=";
  };

  nativeBuildInputs = [
    pkg-config
    gettext
    meson
    ninja
    gobject-introspection
    wrapGAppsHook
    python3
    desktop-file-utils
  ];

  buildInputs = [
    gjs
    glib
    gtk4
    gdk-pixbuf
    libadwaita
  ] ++ (with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad # for gstreamer-player-1.0
  ]);

  postPatch = ''
    chmod +x build-aux/meson_post_install.py
    patchShebangs build-aux/meson_post_install.py
  '';

  passthru = {
    updateScript = gnome.updateScript {
      packageName = pname;
      attrPath = "gnome.${pname}";
    };
  };

  meta = with lib; {
    description = "A simple and modern sound recorder";
    mainProgram = "gnome-sound-recorder";
    homepage = "https://wiki.gnome.org/Apps/SoundRecorder";
    license = licenses.gpl2Plus;
    maintainers = teams.gnome.members;
    platforms = platforms.linux;
  };
}
