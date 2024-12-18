from rosidl_adapter.msg import convert_msg_to_idl
from rosidl_adapter.srv import convert_srv_to_idl
from pathlib import Path
import os
import shutil

if __name__ == "__main__":
    # initialize path
    root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    fast_dds_gen_bin_path = os.path.join(root_dir, "Tools/fastddsgen.jar")

    # for all pkgs dirs
    for pkg_name in os.listdir(os.path.join(root_dir, "ROSMessages")):
        print(f">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Processing Package: {pkg_name}")
        print(f"------------- [{pkg_name}] Stage 1: ROSMsg -> Idl -------------")
        pkg_dir = os.path.join(root_dir, f"ROSMessages/{pkg_name}")
        ros_msg_folder = os.path.join(pkg_dir, "msg")
        ros_srv_folder = os.path.join(pkg_dir, "srv")
        process_msg_folder = os.path.join(pkg_dir, "modified_msg")
        process_srv_folder = os.path.join(pkg_dir, "modified_srv")
        ros_msg_output_folder = os.path.join(root_dir, f"ROSIdlMessages/{pkg_name}")
        ros_srv_output_folder = os.path.join(root_dir, f"ROSIdlMessages/{pkg_name}")

        # preprocess msg, fastdds gen not support .idl files with .msg if first line is comment
        # create folders
        if not os.path.exists(process_msg_folder):
            os.makedirs(process_msg_folder)
        if not os.path.exists(process_srv_folder):
            os.makedirs(process_srv_folder)

        # convert .msg files
        for dirpath, _, filenames in os.walk(ros_msg_folder):
            for filename in filenames:
                msg_filename = os.path.join(dirpath, filename)
                msg_modified_filename = os.path.join(process_msg_folder, filename)
                with open(msg_filename, 'r', encoding='utf-8') as infile, open(msg_modified_filename, 'w', encoding='utf-8') as outfile:
                    lines = infile.readlines()
                    if lines:  # 确保文件不为空
                        # 确保文件开头不为注释
                        while "#" in lines[0][0:3]:
                            lines.pop(0)
                        outfile.writelines(lines)
                convert_msg_to_idl(pkg_name, Path(msg_modified_filename), Path(ros_msg_output_folder))

        # convert .srv files
        for dirpath, _, filenames in os.walk(ros_srv_folder):
            for filename in filenames:
                srv_filename = os.path.join(dirpath, filename)
                srv_modified_filename = os.path.join(process_srv_folder, filename)
                with open(srv_filename, 'r', encoding='utf-8') as infile, open(srv_modified_filename, 'w', encoding='utf-8') as outfile:
                    lines = infile.readlines()
                    if lines:  # 确保文件不为空
                        # 确保文件开头不为注释
                        while "#" in lines[0][0:3]:
                            lines.pop(0)
                        outfile.writelines(lines)
                convert_srv_to_idl(pkg_name, Path(srv_modified_filename), Path(ros_srv_output_folder))
        
        # handle strange error
        for dirpath, _, filenames in os.walk(ros_msg_output_folder):
            for filename in filenames:
                idl_filename = os.path.join(dirpath, filename)
                with open(idl_filename, 'r', encoding='utf-8') as f:
                    content = f.read()
                    # avoid interface reserver word
                    content = content.replace("interface", "_interface")
                    # avoid map reserver word
                    content = content.replace("map", "_map")
                with open(idl_filename, 'w', encoding='utf-8') as f:
                    f.write(content)

        # handle strange error
        for dirpath, _, filenames in os.walk(ros_srv_output_folder):
            for filename in filenames:
                idl_filename = os.path.join(dirpath, filename)
                with open(idl_filename, 'r', encoding='utf-8') as f:
                    content = f.read()
                    # avoid interface reserver word
                    content = content.replace("interface", "_interface")
                    # avoid map reserver word
                    content = content.replace("map", "_map")
                with open(idl_filename, 'w', encoding='utf-8') as f:
                    f.write(content)

        # Remove Temp Messages
        shutil.rmtree(process_msg_folder)
        shutil.rmtree(process_srv_folder)

        # Idl files -> Cpp files
        print(f"------------- [{pkg_name}] Stage 2: Idl -> Cpp -------------")
        pkg_cpp_msg_folder = os.path.join(root_dir, f"ROSCppMessages/{pkg_name}")
        # create folders
        if not os.path.exists(pkg_cpp_msg_folder):
            os.makedirs(pkg_cpp_msg_folder)
        
        # fast-dds-gen generate cpp files
        os.chdir(ros_msg_output_folder)
        os.system(f"java -jar {fast_dds_gen_bin_path} -replace -typeros2 -d {pkg_cpp_msg_folder} *.idl")

        # .cxx -> .cpp
        cpp_messages_dir = pkg_cpp_msg_folder
        # handle with cxx files
        for dirpath, _, filenames in os.walk(cpp_messages_dir):
            for filename in filenames:
                # get basename and extension
                basename, extension = os.path.splitext(filename)

                # exclude not cxx files
                if extension != ".cxx":
                    continue

                # read cxx file
                cxx_filename = os.path.join(dirpath, filename)
                with open(cxx_filename, 'r') as f:
                    cxx_content = f.read()

                # generate cpp file
                cpp_filename = os.path.join(dirpath, basename + ".cpp")
                cpp_content = "#pragma warning(disable : 4583)\n#pragma warning(disable : 4583)\n" + cxx_content
                with open(cpp_filename, 'w') as f:
                    f.write(cpp_content)

                # remove cxx file
                os.remove(cxx_filename)
                print(f"已导出消息文件 {basename + ".cpp"}.")
        
        # Output information
        print(f"------------- [{pkg_name}] Generate Finished -------------")
