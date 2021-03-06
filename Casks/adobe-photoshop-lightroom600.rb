cask :v1 => 'adobe-photoshop-lightroom600' do
  version '6.0'
  sha256 '5c36e5fa76b8676144c4bba9790fe4c597daf350b2195a2088346b097f46a95f'

  url "http://trials3.adobe.com/AdobeProducts/LTRM/#{version.to_i}/osx10/Lightroom_#{version.to_i}_LS11.dmg",
    :user_agent => :fake,
    :cookies => { 'MM_TRIALS' => '1234' }
  name 'Adobe Photoshop Lightroom'
  homepage 'https://www.adobe.com/products/photoshop-lightroom.html'
  license :commercial

  # staged_path not available in Installer/Uninstall Stanza, workaround by nesting with preflight/postflight
  # see https://github.com/caskroom/homebrew-cask/pull/8887
  # and https://github.com/caskroom/homebrew-versions/pull/296

  preflight do
    system '/usr/bin/killall', '-kill', 'SafariNotificationAgent'
    system '/usr/bin/sudo', '-E', '--', "#{staged_path}/Install.app/Contents/MacOS/Install", '--mode=silent', "--deploymentFile=#{staged_path}/deploy/AdobeLightroom6.install.xml"
  end

  uninstall_preflight do
    system '/usr/bin/killall', '-kill', 'SafariNotificationAgent'
    system '/usr/bin/sudo', '-E', '--', "#{staged_path}/Install.app/Contents/MacOS/Install", "--mode=silent", "--deploymentFile=#{staged_path}/deploy/AdobeLightroom6.remove.xml"
  end

  uninstall :delete => "/Applications/Adobe Lightroom/Adobe Lightroom.app"
  zap       :delete => [
                        '~/Library/Application Support/Adobe/Lightroom',
                        "~/Library/Preferences/com.adobe.Lightroom#{version.to_i}.plist",
                       ]

  caveats 'Installation or Uninstallation may fail with Exit Code 19 (Conflicting Processes running) if Browsers, Safari Notification Service or SIMBL Services are running or Adobe Creative Cloud or any other Adobe Products are already installed. See Logs in /Library/Logs/Adobe/Installers if Installation or Uninstallation fails, to identify the conflicting processes.'
end
