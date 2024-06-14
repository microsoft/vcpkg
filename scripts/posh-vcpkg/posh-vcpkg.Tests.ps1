BeforeAll {
    Import-Module $PSScriptRoot/posh-vcpkg
}

Describe 'Module posh-vcpkg tests' {

    BeforeAll {

        function Complete-InputCaret {
            [OutputType([System.Management.Automation.CommandCompletion])]
            param (
                [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
                [string]$caretCursorCommand
            )
            $positionMatches = [regex]::Matches($caretCursorCommand, '\^')
            if ($positionMatches.Count -ne 1) {
                throw 'Invalid caret cursor command, please indicate by only one ^ character'
            }
            else {
                $command = [string]$caretCursorCommand.Replace('^', '');
                $cursorPosition = [int]$positionMatches[0].Index;
                return [System.Management.Automation.CommandCompletion]::CompleteInput($command, $cursorPosition, $null)
            }
        }

        function Expand-CompletionText {
            param (
                [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
                [System.Management.Automation.CommandCompletion]$CommandCompletion
            )
            return $CommandCompletion.CompletionMatches | Select-Object -ExpandProperty CompletionText
        }

    }

    Context 'Internal function tests' {

        It 'Complete-InputCaret 1 caret string should success' {
            'aaaa^' | Complete-InputCaret | Should -Not -BeNullOrEmpty
        }

        It 'Complete-InputCaret 0 caret string should throw' {
            { 'aaaa' | Complete-InputCaret } | Should -Throw
        }

        It 'Complete-InputCaret 2 caret string should throw' {
            { 'aaaa^^' | Complete-InputCaret } | Should -Throw
        }

        It 'Expand-CompletionText self should success' {
            $inputStr = 'Expand-CompletionText^'
            $res = $inputStr | Complete-InputCaret
            $res | Expand-CompletionText | Should -Contain 'Expand-CompletionText'
        }

    }

    Context 'Complete command name tests' {

        It 'Should complete command word <comment> [<caretCmd>]' -TestCases (
            @{ comment = 'without word'; caretCmd = 'vcpkg ^'; expectedContain = 'version' },
            @{ comment = 'with word'; caretCmd = 'vcpkg ver^'; expectedContain = 'version' },
            @{ comment = 'with native exe'; caretCmd = 'vcpkg.exe ver^'; expectedContain = 'version' },
            @{ comment = 'with dot slash'; caretCmd = './vcpkg ver^'; expectedContain = 'version' },
            @{ comment = 'with dot backslash'; caretCmd = '.\vcpkg ver^'; expectedContain = 'version' }
        ) {
            param($caretCmd, $expectedContain, $comment)
            $caretCmd | Complete-InputCaret | Expand-CompletionText | Should -Contain $expectedContain
        }

    }

    Context 'Complete command spaces tests' {

        It 'Should complete command <comment> [<caretCmd>]' -TestCases (
            @{ comment = 'spaces without argument'; caretCmd = 'vcpkg     ^'; expectedContain = 'version' },
            @{ comment = 'before remaining'; caretCmd = 'vcpkg     ver^'; expectedContain = 'version' },
            # @{ comment = 'with trailing spaces'; caretCmd = 'vcpkg ver     ^'; expectedContain = 'version' },
            @{ comment = 'with leading spaces'; caretCmd = '     vcpkg ver^'; expectedContain = 'version' }
        ) {
            param($caretCmd, $expectedContain, $comment)
            $caretCmd | Complete-InputCaret | Expand-CompletionText | Should -Contain $expectedContain
        }

        It 'Should complete command with trailing spaces [vcpkg ver     ^]' -Skip {
            'vcpkg ver     ^' | Complete-InputCaret | Expand-CompletionText | Should -Contain 'version'
        }

    }

    Context 'Complete command quotation tests' -Skip {

        It "Should complete command with quoted word [vcpkg 'ver'^]" {
            "vcpkg 'ver'^" | Complete-InputCaret | Expand-CompletionText | Should -Contain 'version'
        }

        It "Should complete command with quoted space [vcpkg ' '^]" {
            "vcpkg 'ver'^" | Complete-InputCaret | Expand-CompletionText | Should -Contain 'version'
        }

        It "Should complete command with quoted word [vcpkg 'version'^]" {
            "vcpkg 'ver'^" | Complete-InputCaret | Expand-CompletionText | Should -Contain 'version'
        }

    }

    Context 'Complete command intermediate tests' {

        It 'Should complete command <comment> [<caretCmd>]' -TestCases (
            @{ comment = 'end of word'; caretCmd = 'vcpkg version^'; expectedContain = 'version' },
            @{ comment = 'middle of word'; caretCmd = 'vcpkg ver^sion'; expectedContain = 'version' },
            @{ comment = 'front of word'; caretCmd = 'vcpkg ^version'; expectedContain = 'version' }
        ) {
            param($caretCmd, $expectedContain, $comment)
            $caretCmd | Complete-InputCaret | Expand-CompletionText | Should -Contain $expectedContain
        }

    }

    Context 'Complete subcommand tests' {

        It 'Should complete subcommand [<expected>] from [<caretCmd>]' -TestCases (
            @{ caretCmd = 'vcpkg depend^'; expected = 'depend-info' },
            @{ caretCmd = 'vcpkg inst^'; expected = 'install' },
            @{ caretCmd = 'vcpkg int^'; expected = 'integrate' },
            @{ caretCmd = 'vcpkg rem^'; expected = 'remove' }
        ) {
            param($caretCmd, $expected)
            @($caretCmd | Complete-InputCaret | Expand-CompletionText)[0] | Should -BeExactly $expected
        }

        It 'Should complete subcommand two-level [powershell] from [vcpkg integrate power^]' -Skip {
            'vcpkg integrate power^' | Complete-InputCaret | Expand-CompletionText | Should -Contain 'powershell'
        }

    }

    Context 'Complete subcommand argument and options tests' -Skip {

        It 'Should complete argument [<expected>] from [<caretCmd>]' -TestCases (
            @{ caretCmd = 'vcpkg install vcpkg-cmake^'; expectedContain = 'vcpkg-cmake-get-vars' },
            @{ caretCmd = 'vcpkg install vcpkg-cmake --^'; expectedContain = '--dry-run' }
        ) {
            param($caretCmd, $expected)
            $caretCmd | Complete-InputCaret | Expand-CompletionText | Should -Contain $expectedContain
        }

    }

    Context 'Complete complex tests' {

        It 'Should complete complex line [<expected>] from [<caretCmd>]' -TestCases (
            @{ caretCmd = 'echo powershell | % { vcpkg ver^ $_ }; echo $?'; expectedContain = 'version' }
        ) {
            param($caretCmd, $expected)
            $caretCmd | Complete-InputCaret | Expand-CompletionText | Should -Contain $expectedContain
        }

    }

}
