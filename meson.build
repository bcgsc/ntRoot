project('ntRoot',
        version : '1.0.0',
        license : 'GPL-3')

subproject('ntEdit')
subdir('bin')

scripts = ['ntroot', 'ntroot_run_pipeline.smk']

install_data(scripts, install_dir : 'bin', install_mode : 'rwxr-xr--')

rootpath = meson.source_root()
