require 'formula'

class Ab < Formula
  homepage 'http://httpd.apache.org/docs/trunk/programs/ab.html'
  url 'http://archive.apache.org/dist/httpd/httpd-2.4.3.tar.bz2'
  sha1 '0ef1281bb758add937efe61c345287be2f27f662'

  depends_on 'homebrew/dupes/apr-util'
  depends_on 'libtool' => :build

  option 'with-ssl-patch', 'Apply patch for: Bug 49382 - ab says "SSL read failed"'

  def patches
    # Disable requirement for PCRE, because "ab" does not use it
    patches = {
      :p1 => DATA,
    }

    # Patch for https://issues.apache.org/bugzilla/show_bug.cgi?id=49382
    # Upstream has not incorporated the patch. Should keep following
    # what upstream do about this.
    if build.with? 'ssl-patch'
      patches[:p0] = 'https://issues.apache.org/bugzilla/attachment.cgi?id=28435'
    end

    patches
  end

  def install
    # Mountain Lion requires this to be set, as otherwise libtool complains
    # about being "unable to infer tagged configuration"
    ENV['LTFLAGS'] = '--tag CC'
    system "./configure", "--prefix=#{prefix}", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--with-apr=/opt/boxen/homebrew/opt/apr",
                          "--with-apr-util=#{Formula["homebrew/dupes/apr-util"].opt_prefix}"

    cd 'support' do
      system 'make', 'ab'
      # We install into the "bin" directory, although "ab" would normally be
      # installed to "/usr/sbin/ab"
      bin.install('ab')
    end
    man1.install('docs/man/ab.1')
  end

  test do
    system *%W{#{bin}/ab -k -n 10 -c 10 http://www.apple.com/}
  end
end

__END__
diff --git a/configure b/configure
index 5f4c09f..84d3de2 100755
--- a/configure
+++ b/configure
@@ -6037,8 +6037,6 @@ $as_echo "$as_me: Using external PCRE library from $PCRE_CONFIG" >&6;}
     done
   fi

-else
-  as_fn_error $? "pcre-config for libpcre not found. PCRE is required and available from http://pcre.org/" "$LINENO" 5
 fi

   APACHE_VAR_SUBST="$APACHE_VAR_SUBST PCRE_LIBS"
