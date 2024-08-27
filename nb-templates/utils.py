#!/usr/bin/env python
# -*- coding: utf-8 -*-

from qiime2.plugins.feature_table.methods import filter_samples
from qiime2.plugins.feature_table.methods import filter_seqs

def filter_samples(metadata, tabs, reps)
    # Filter FeatureTable[Frequency | RelativeFrequency | PresenceAbsence | Composition] based on Metadata sample ID values
    tabs = filter_samples(
        table=tabs,
        metadata=metadata,
    ).filtered_table
    # Filter SampleData[SequencesWithQuality | PairedEndSequencesWithQuality | JoinedSequencesWithQuality] based on Metadata sample ID values; returns FeatureData[Sequence | AlignedSequence]
    reps = filter_seqs(
        data=reps,
        table=tabs,
    ).filtered_data
    return tabs, reps



def get_direction_info(manifest_file_path):
    """Process and gets information about fastq directions using manifest file
    
    Example:
        d_type, v_type, direction = get_direction_info(manifest_file)
        print('\n'.join([d_type, v_type, direction]))

    Parameters:
    manifest_file_path (str): manifest file with all sample input paths

    Returns:
    str: QIIME2 input data type
    str: QIIME2 Manifest file type
    str: Direction type

    """
    d_type, v_type, direction = None, None, None
    manifest_df = pd.read_csv(manifest_file)
    n_directions = len(manifest_df['direction'].unique())
    if n_directions == 1:
        d_type = 'SampleData[SequencesWithQuality]'
        v_type = 'SingleEndFastqManifestPhred33'
        direction = 'single'
    elif n_directions == 2:
        d_type = 'SampleData[PairedEndSequencesWithQuality]'
        v_type = 'PairedEndFastqManifestPhred33'
        direction = 'paired'
    else:
        print(f'ERROR: invalid number of directions {n_directions}')
    return d_type, v_type, direction


