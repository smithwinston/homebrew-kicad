require 'formula'


class Kicad < Formula
  homepage 'https://launchpad.net/kicad'
  head "http://bazaar.launchpad.net/~kicad-product-committers/kicad/product/", :using => :bzr

  depends_on 'bazaar'
  depends_on 'cmake' => :build
  depends_on :x11
  depends_on 'Wxmac'
  depends_on 'GLEW'
  depends_on 'Cairo'

  def patches
	DATA
  end

  def install

    args = std_cmake_args + %W[
        -DKICAD_TESTING_VERSION=ON
        -DCMAKE_CXX_FLAGS=-D__ASSERTMACROS__
        -DCMAKE_OSX_ARCHITECTURES=#{MacOS.preferred_arch}
      ]

    system "cmake", ".", *args

    # fix the osx search path for the library components to the homebrew directory
    inreplace 'common/edaappl.cpp','/Library/Application Support', "#{HOMEBREW_PREFIX}/share/kicad"

    system "make install"
  end

  def caveats; <<-EOS.undent
    kicad.app and friends installed to:
      #{bin}

    If you get "bzr: ERROR: unknown command "patch"" error, then you should probably install bzrtools:

      wget -O /tmp/bzrtools.tar.gz http://launchpad.net/bzrtools/stable/2.5/+download/bzrtools-2.5.tar.gz
      mkdir -p ~/.bazaar/plugins/
      tar zxf /tmp/bzrtools.tar.gz -C ~/.bazaar/plugins/

    To link the application to a normal Mac OS X location:
        brew linkapps
    or:
        ln -s #{bin}/bitmap2component.app /Applications
        ln -s #{bin}/cvpcb.app /Applications
        ln -s #{bin}/eeschema.app /Applications
        ln -s #{bin}/gerbview.app /Applications
        ln -s #{bin}/kicad.app /Applications
        ln -s #{bin}/pcb_calculation.app /Applications
        ln -s #{bin}/pcbnew.app /Applications
    EOS
  end

  def test
    # run main kicad UI
    system "open #{bin}/kicad.app"
  end
end

__END__
diff --git a/CMakeModules/download_boost.cmake b/CMakeModules/download_boost.cmake
index dd72e7c..2e42fdd 100644
--- a/CMakeModules/download_boost.cmake
+++ b/CMakeModules/download_boost.cmake
@@ -272,6 +272,7 @@ mark_as_advanced( Boost_LIBRARIES Boost_INCLUDE_DIR )
 
 
 ExternalProject_Add_Step( boost bzr_commit_boost
+    COMMAND bzr whoami --branch --directory <SOURCE_DIR> "Kicad Build <nobody@example.com>"
     COMMAND bzr ci -q -m pristine <SOURCE_DIR>
     COMMENT "committing pristine boost files to 'boost scratch repo'"
     DEPENDERS patch
