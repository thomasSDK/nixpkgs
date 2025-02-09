{ lib
, buildPythonPackage
, cffi
, coloredlogs
, fetchFromGitHub
, ghostscript
, img2pdf
, importlib-resources
, jbig2enc
, leptonica
, pdfminer
, pikepdf
, pillow
, pluggy
, pngquant
, pytest-xdist
, pytestCheckHook
, reportlab
, setuptools
, setuptools-scm
, setuptools-scm-git-archive
, stdenv
, substituteAll
, tesseract4
, tqdm
, unpaper
}:

buildPythonPackage rec {
  pname = "ocrmypdf";
  version = "12.6.0";

  src = fetchFromGitHub {
    owner = "jbarlow83";
    repo = "OCRmyPDF";
    rev = "v${version}";
    # The content of .git_archival.txt is substituted upon tarball creation,
    # which creates indeterminism if master no longer points to the tag.
    # See https://github.com/jbarlow83/OCRmyPDF/issues/841
    extraPostFetch = ''
      rm "$out/.git_archival.txt"
    '';
    sha256 = "0zw7c6l9fkf128gxsbd7v4abazlxiygqys6627jpsjbmxg5jgp5w";
  };

  SETUPTOOLS_SCM_PRETEND_VERSION = version;

  patches = [
    (substituteAll {
      src = ./paths.patch;
      gs = "${lib.getBin ghostscript}/bin/gs";
      jbig2 = "${lib.getBin jbig2enc}/bin/jbig2";
      liblept = "${lib.getLib leptonica}/lib/liblept${stdenv.hostPlatform.extensions.sharedLibrary}";
      pngquant = "${lib.getBin pngquant}/bin/pngquant";
      tesseract = "${lib.getBin tesseract4}/bin/tesseract";
      unpaper = "${lib.getBin unpaper}/bin/unpaper";
    })
  ];

  nativeBuildInputs = [
    setuptools-scm-git-archive
    setuptools-scm
  ];

  propagatedBuildInputs = [
    cffi
    coloredlogs
    img2pdf
    importlib-resources
    pdfminer
    pikepdf
    pillow
    pluggy
    reportlab
    setuptools
    tqdm
  ];

  checkInputs = [
    pytest-xdist
    pytestCheckHook
  ];

  pythonImportsCheck = [
    "ocrmypdf"
  ];

  meta = with lib; {
    homepage = "https://github.com/jbarlow83/OCRmyPDF";
    description = "Adds an OCR text layer to scanned PDF files, allowing them to be searched";
    license = with licenses; [ mpl20 mit ];
    platforms = platforms.linux;
    maintainers = with maintainers; [ kiwi dotlambda ];
    changelog = "https://github.com/jbarlow83/OCRmyPDF/blob/v${version}/docs/release_notes.rst";
  };
}
