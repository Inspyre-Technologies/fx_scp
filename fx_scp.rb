#!/usr/bin/ruby
require 'fox16'
require 'logger'
include Fox

class FXScp < FXMainWindow
  LOG = Logger.new(STDOUT)
  arguments = ARGV
  @verbose = false
  @verbose = true if ARGV.include?("-v")
  
  case @verbose
  when true
    LOG.level = Logger::DEBUG
  when false
    LOG.level = Logger::WARN
  end

  LOG.debug('Created LOG...')
  LOG.info('FX::SCP Started!')

  def clean_exit
    puts 'Doing exit stuff here'
    exit 0
  end

  def is_active?(task)
    if task == remote
      return false if @remote_created
    elsif task == 0
    end
  end

  def switch_cleanup(task)
    LOG.info('STARTING CLEANUP JOB')
    LOG.debug('Checking to see if conflicting fields exist...')
    
    case task
    when 'remote'
      LOG.debug('Received task to cleanup for new remote pops')
      LOG.debug('Checking to see if remote pops exist')
      LOG.debug('No remote pops found') if !is_active?
    end
  end

  def redraw
    LOG.info('Marking main window for redraw due to changes')
    @packer.recalc
    LOG.info('Main window marked for redraw!')
  end

  LOG.info('Defining necessary variables')
  LOG.debug('Carrying out 2 changes....')

  LOG.debug("Setting @remote_created to 'false'....")
  @remote_created = false
  LOG.debug("@remote_created set to #{@remote_created}") unless @remote_created
  LOG.error("Could not set @remote_created to 'false', this may cause issues later?") if @remote_created

  LOG.debug("Setting @local_created to 'false'....")
  @local_created = false
  LOG.debug("@local_created set to #{@remote_created}") unless @local_created
  LOG.error("Could not set @local_created to 'false', this may cause issues later") if @local_created

  if @local_created || @remote_created
    LOG.warn('Moving forward from here will cause unpredictable behavior. One or more needed variables failed to set.')
  end

  def create_remote
    LOG.info('STARTING CREATE JOB: REMOTE')
    LOG.debug('Setting X Window Properties for remote source settings....')
    LOG.debug('DEFINE BOX: Settings Source Group Box || Target: Main Window')
    @r_box1 = FXGroupBox.new(@packer, 'Source', opts: FRAME_RIDGE | LAYOUT_FILL_X)
    LOG.debug('DEFINE HFRAME: IP Field || TARGET: Source Group Box')
    @frame1 = FXHorizontalFrame.new(@r_box1)
    LOG.debug('Set up IP text field')
    @ip_txt_fld = FXTextField.new(@frame1, 15)
    LOG.debug('DEFINE IP TXT FIELD LABEL: IP')
    @ip_lab = FXLabel.new(@frame1, 'IP address/FQDN of remote server:')
    LOG.debug('DEFINE HFRAME: Password Box in Source Group')
    @frame2 = FXHorizontalFrame.new(@r_box1)
    LOG.debug('DEFINE TEXT FIELD: Password text field')
    @pass_fld = FXTextField.new(@frame2, 15, opts: TEXTFIELD_PASSWD)
    LOG.debug('DEFINE LABEL FOR TEXT FIELD: Password text field')
    @pass_txt_lab = FXLabel.new(@frame2, 'Password of user')
    LOG.info('X Window Properties for source group popped')

    LOG.info('Creating Group....')
    @r_assembly = [
      @r_box1,
      @frame1,
      @ip_txt_fld,
      @ip_lab,
      @frame2,
      @pass_fld,
      @pass_txt_lab,
    ]

    for i in @r_assembly
      LOG.debug("Building Group: Creating #{i.class}")
      i.create
      LOG.debug('CREATED!')
    end

    redraw
    LOG.debug('Marking Remote Group as Created')
    @remote_created = true
    LOG.info('Create job finished!')
  end

  def del_remote
    LOG.info('STARTING DESTROY JOB: REMOTE')

    for i in @r_assembly do
      LOG.debug("DESTROY: #{i.class}")
      i.destroy
      LOG.debug('DESTROYED!')
    end
    LOG.info('Destroy job finished!')

    redraw
    @remote_created = false
  end

  def create_local
    LOG.info('Checking for conflicting fields and deleting if they exist')
    if @remote_created
      LOG.warn('Remote fields already popped, calling on destroy job')
      del_remote
      LOG.debug('')
    end
    if @local_created
      LOG.warn('Local already popped, calling on destroy job')
      del_local
    end
    del_local if @local_created
    @l_box1 = FXGroupBox.new(@packer, 'Source', opts: FRAME_RIDGE | LAYOUT_FILL_X)
    @frame1 = FXHorizontalFrame.new(@l_box1)
    @file_button = FXButton.new(@l_box1, 'Select File(s)/Directory', opts: FRAME_RAISED | FRAME_THICK | JUSTIFY_NORMAL)
    @file_button.connect(SEL_COMMAND) do
      @file_dialog = FXFileDialog.getOpenFilenames(@l_box1, 'Select File(s)', `echo $HOME`.chomp + '/')
      redraw
    end
    redraw
    @local_created = true
  end

  def del_local
    @frame1.destroy
    @file_button.destroy
    @local_created = false
    @packer.recalc
  end

  def initialize(app)
    super(app, 'FXscp', width: 800, height: 600)

    @packer = FXPacker.new(self, opts: LAYOUT_FILL)

    @choice_frame = FXHorizontalFrame.new(@packer)

    @radio_group = FXDataTarget.new(0)

    FXRadioButton.new(@choice_frame, 'Remote', @radio_group, FXDataTarget::ID_OPTION)
    FXRadioButton.new(@choice_frame, 'Local', @radio_group, FXDataTarget::ID_OPTION + 1)
    FXRadioButton.new(@choice_frame, 'All Remote', @radio_group, FXDataTarget::ID_OPTION + 2)

    @radio_group.connect(SEL_COMMAND) do
      create_remote if @radio_group.value.zero?

      create_local if @radio_group.value == 1
    end

    res_box = FXGroupBox.new(@packer, 'Operations', opts: FRAME_RIDGE | LAYOUT_FILL_X)

    begin_button = FXButton.new(res_box, 'Begin SCP', opts: BUTTON_AUTOGRAY)
  end

  def create
    super
    show(PLACEMENT_SCREEN)
  rescue StandardError
    puts caller
    exit 1
  end

  if $PROGRAM_NAME == __FILE__
    FXApp.new do |app|
      FXScp.new(app)
      app.create
      app.run
    end
  end
end
