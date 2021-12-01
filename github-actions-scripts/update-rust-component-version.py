import os, json
import requests
import datetime
import re
from github import Github


GITHUB_REPO = "mozilla/rust-components-swift"
BLOCKZILLA = "Blockzilla.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"

BLOCKZILLA_PROJECT = "Blockzilla.xcodeproj/project.pbxproj"
github_access_token = os.getenv("GITHUB_TOKEN")

def get_latest_rust_components_version():
    g = Github()
    repo = g.get_repo(GITHUB_REPO)

    latest_tag = repo.get_tags()[0].name
    latest_commit = str(repo.get_tags()[0].commit)
    only_commit = re.findall(r'"([^"]*)"', latest_commit)

    return (str(latest_tag), str(only_commit[0]))

def read_rust_components_tag_version():
    # Read Package to find the current rust-component version
    f = open(BLOCKZILLA)
    data = json.load(f)

    pin = data["object"]

    for i in pin["pins"]:
        if i["package"] == "MozillaRustComponentsSwift":
            # return the json with the RustComponent info
            json_new_version = i["state"]
            #print(i["state"])
    f.close()

    print (json_new_version["revision"])
    return json_new_version["version"], json_new_version["revision"]

def read_project_min_version():
    line_number = 0
    list_of_results = []
    string_to_search = 'https://github.com/mozilla/rust-components-swift'

    with open(BLOCKZILLA_PROJECT) as f:
        #if 'https://github.com/mozilla/rust-components-swift' in f.read():
        line_read = 0
        for line in f:
            # For each line, check if line contains the string
            line_number += 1
            if string_to_search in line:
                # If yes, then look for the field we are interested in: minimumVersion
                for i in range(3):
                    my_line=next(f, '').strip()
                #print(my_line)

                version_found = my_line.find("=")
                last_line_position = my_line.find(";")
                current_tag_version = ''
                # version format: XX.Y.Z
                for i in range(version_found+2 , last_line_position):
                    #print(my_line[i])
                    current_tag_version+=my_line[i]
                print (current_tag_version)
                return current_tag_version

def compare_versions(current_tag_version, repo_tag_version):
    # Compare a-s version used and the latest available in a-s repo
    if current_tag_version < repo_tag_version:
        print("Update Rust componet version and create PR")
        return True
    else:
        print("No new versions, skip")
        return False

def update_spm_file(current_tag, current_commit, as_repo_tag, as_repo_commit, file_name):
    # Read the Cartfile and Cartife.resolved, update
    file = open(file_name, "r+")
    data = file.read()
    data = data.replace(current_tag, as_repo_tag)
    data = data.replace(current_commit, as_repo_commit)
    file.close()
    
    file = open(file_name, "wt")
    file.write(data)
    file.close()


def update_proj_file(current_tag, as_repo_tag, file_name):
    file = open(file_name, "r+")
    data = file.read()
    data = data.replace(current_tag, as_repo_tag)

    file.close()
    
    file = open(file_name, "wt")
    file.write(data)
    file.close()

#read_rust_components_tag_version()

#read_project_min_version()


def main():
    
    '''
    STEPS
    1. check Rust Components repo for latest tagged version
    2. compare latest with current SPM and project versions in repo 
    3. if same version exit, if not, continue 
    4. update both SMP and project files
    
    '''

    as_repo_tag, as_repo_commit = get_latest_rust_components_version()
    current_tag, current_commit = read_rust_components_tag_version()
    current_min_version  = read_project_min_version()
    if compare_versions(current_tag, as_repo_tag):
        print("Compared")

        update_spm_file(current_tag, current_commit, as_repo_tag, as_repo_commit, BLOCKZILLA)
        update_proj_file(current_min_version, as_repo_tag, BLOCKZILLA_PROJECT)


if __name__ == '__main__':
    main()
