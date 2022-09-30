from typing import Optional
from pathlib import Path

def params(*args):
    string = ' '.join((str(x) for x in args))
    return string

def mkpath(*args):
    s = os.path.join(*args)
    return s

def add_step(name, step):
    name, ext = name[:-4], name[-4:]
    new_name = name + '_' + step + ext
    return new_name

def chext(name, ext):
    new_name = name.split('.')[0] + f'.{ext}'
    return new_name

def clean_str(params_str):
    cleaned = ' '.join([x for x in params_str.split('\n') if len(x)>0]).strip()
    cleaned = re.sub(' +', ' ', cleaned)
    return cleaned

def cmd_exec(cmd, tmp_path='tmp_cmd.sh'):
    msg = f'''
conda activate qiime2; \
{cmd} \
conda deactivate; \
    '''
    msg = '#!/bin/bash \n' + clean_str(msg)
    return msg

def qzv(name):
    return f'{name[:-1]}v'

def get_artifacts(group: str, phred: int, root: Path, exp_name: Optional[str] = None) -> dict:
    from qiime2 import Artifact
    infos = dict()
    if exp_name:
        experiment_dir = exp_name
    else:
        experiment_dir = f'{group}-phred_{phred}-tf_0-tr_0-lap_4'
        
    base_dir = Path(root, experiment_dir)
    infos['reps'] = Artifact.load(Path(base_dir, f'{group}_dada2_reps.qza'))
    infos['tabs'] = Artifact.load(Path(base_dir, f'{group}_dada2_tabs.qza'))
    infos['stat'] = Artifact.load(Path(base_dir, f'{group}_dada2_stat.qza'))
    infos['taxs'] = Artifact.load(Path(base_dir, f'{group}_dada2_reps_tax.qza'))
    return infos

# ====== PLOT ======
def plot_stats_box(artifact, fname):
    import matplotlib.pyplot as plt
    from qiime2 import Metadata
    
    values_head = ['input', 'filtered', 'denoised', 'merged', 'non-chimeric']
    percent_head = ['percentage of input passed filter', 'percentage of input merged', 'percentage of input non-chimeric']
    
    df = artifact.view(Metadata).to_dataframe()
    df_vals = df[values_head]
    df_perc = df[percent_head]
    df_perc.columns = ['filtered', 'merged', 'non-chimeric']
    
    
    plt.figure(figsize=(15,5))
    plt.subplot(1, 2, 1)
    df_vals.boxplot()
    plt.xlabel('Fases')
    plt.ylabel('# of reads')
    
    plt.subplot(1, 2, 2)
    df_perc.boxplot()
    plt.xlabel('Fases')
    plt.ylabel('% of input')
    
    plt.savefig(fname, bbox_inches='tight')

    plt.show()
    

def plot_stats_box_pairs(p1, p2):
    import pandas as pd
    import seaborn as sns
    import matplotlib.pyplot as plt
    from qiime2 import Metadata
    
    values_head = ['input', 'filtered', 'denoised', 'merged', 'non-chimeric']
    percent_vals_old = ['percentage of input passed filter', 'percentage of input merged', 'percentage of input non-chimeric']
    percent_vals_new = ['%filtered', '%merged', '%non-chimeric']
    percent_head = dict(zip(percent_vals_old, percent_vals_new))
    
    df1 = p1.view(Metadata).to_dataframe()
    df1.rename(columns=percent_head, inplace=True)
    
    df2 = p2.view(Metadata).to_dataframe()
    df2.rename(columns=percent_head, inplace=True)

    df_4 = df1[values_head].assign(group='overlap-4')
    df_12 = df2[values_head].assign(group='overlap-12')
    
    plt.figure(figsize=(15,5))
    plt.subplot(1, 2, 1)
    cdf = pd.concat([df_4, df_12])
    mdf = pd.melt(cdf, id_vars=['group'], var_name=['Step'])
    ax = sns.boxplot(x="Step", y="value", hue="group", data=mdf)
    ax.set_xlabel('Etapa')
    ax.set_ylabel('# reads')
    
    df_4 = df1[percent_head.values()].assign(group='overlap-4')
    df_12 = df2[percent_head.values()].assign(group='overlap-12')
    
    plt.subplot(1, 2, 2)
    cdf = pd.concat([df_4, df_12])
    mdf = pd.melt(cdf, id_vars=['group'], var_name=['Step'])
    ax = sns.boxplot(x="Step", y="value", hue="group", data=mdf)
    ax.tick_params(axis='x', labelrotation=45)
    ax.set_xlabel('Etapa')
    ax.set_ylabel('% of input')
    
    plt.show()
    
# ====== TOP COUNTS ======
def top_counts(df, col_idx, top, filtering):
    indexes = []
    species = []
    counts = []
    tax_names = []
    cnt = 0
    
    for i, v in df.sort_values(by=col_idx, ascending=False).iteritems():
        print(v)
        return
        name = v['fulltax'].split(';')[-1]
        invalid_flag = False
        if name != '__':
            name = name[3:]
            if not filtering:
                cnt += 1
                species.append(name)
                counts.append(int(v))
                tax_names.append(v['fulltax'])
                indexes = i
            else:
                invalid_names = ('uncultured', 'microbiom', 'metagenome', 'human_', '_bacterium')
                for invalid in invalid_names:
                    if invalid in name:
                        invalid_flag = True
                        break
                if not invalid_flag:
                    cnt += 1
                    species.append(name)
                    counts.append(int(v))
                    tax_names.append(v['fulltax'])
                    indexes = i
            if cnt >= top:
                break
    return species, counts, tax_names, indexes

def top_plot(df, top, tax, col_values):
    tmp_df = df.groupby([tax])[col_values].apply(lambda x : x.astype(int).sum())
    tmp_df.sort_values(ascending=False, inplace=True)
    tmp_df = tmp_df[:10]
    return tmp_df
    