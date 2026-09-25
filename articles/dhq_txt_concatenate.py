# Source - https://stackoverflow.com/a/29685509
# Posted by LampPost, modified by community. See post 'Timeline' for change history
# Retrieved 2026-05-06, License - CC BY-SA 3.0

RootDir1 = r'*your directory*'
TargetFolder = r'*your target folder*'
for root, dirs, files in os.walk((os.path.normpath(RootDir1)), topdown=False):
        for name in files:
            if name.endswith('.csv'):
                print "Found"
                SourceFolder = os.path.join(root,name)
                shutil.copy2(SourceFolder, TargetFolder) #copies csv to new folder
